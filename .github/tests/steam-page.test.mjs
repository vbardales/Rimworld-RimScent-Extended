import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { fetchImageDigest, fetchPage } from '../scripts/steam-page.mjs';

const answer = (body, ok = true, status = 200) => async () => ({ ok, status, json: async () => body, arrayBuffer: async () => Buffer.from(body) });

test('reads the title, description, tags and preview address of a public item', async () => {
  let request;
  const item = { result: 1, title: 'T', description: 'D', preview_url: 'https://img', time_updated: 5, tags: [{ tag: 'Mod' }, { tag: '1.6' }] };
  const fake = async (url, init) => { request = { url, body: init.body.toString() }; return { ok: true, json: async () => ({ response: { publishedfiledetails: [item] } }) }; };
  assert.deepEqual(await fetchPage('123', fake), { title: 'T', description: 'D', previewUrl: 'https://img', updated: 5, tags: ['Mod', '1.6'] });
  assert.match(request.body, /publishedfileids%5B0%5D=123/);
});

test('every request carries a timeout, so a stalled connection cannot hang the dry-run', async () => {
  const signals = [];
  const item = { result: 1, title: 'T' };
  const fake = async (url, init) => { signals.push(init?.signal); return { ok: true, json: async () => ({ response: { publishedfiledetails: [item] } }), arrayBuffer: async () => Buffer.from('x') }; };
  await fetchPage('1', fake);
  await fetchImageDigest('https://img', fake);
  assert.equal(signals.length, 2);
  for (const signal of signals) assert.ok(signal instanceof AbortSignal);
});

test('an item without tags has an empty list', async () => {
  const fake = answer({ response: { publishedfiledetails: [{ result: 1, title: 'T' }] } });
  assert.deepEqual((await fetchPage('1', fake)).tags, []);
});

test('fails clearly when Steam has no such item or answers with an error', async () => {
  await assert.rejects(fetchPage('1', answer({ response: { publishedfiledetails: [{ result: 9 }] } })), /no public details for item 1/);
  await assert.rejects(fetchPage('1', answer({}, false, 503)), /answered 503/);
});

test('hashes the image the page serves', async () => {
  const expected = createHash('sha256').update('image bytes').digest('hex');
  assert.deepEqual(await fetchImageDigest('https://img', answer('image bytes')), { bytes: 11, sha256: expected });
  await assert.rejects(fetchImageDigest('https://img', answer('', false, 404)), /answered 404/);
});
