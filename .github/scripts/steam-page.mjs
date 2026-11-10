import { digest } from './preview.mjs';

const TIMEOUT_MS = 15000;
const DETAILS = 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/';

// What the public page serves today, read without any login, so the dry-run can compare it with
// what an update would send. A network failure is reported by the caller, never fatal.
export async function fetchPage(workshopId, fetchImpl = fetch) {
  const response = await fetchImpl(DETAILS, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ itemcount: '1', 'publishedfileids[0]': workshopId }),
    signal: AbortSignal.timeout(TIMEOUT_MS),
  });
  if (!response.ok) throw new Error(`Steam answered ${response.status}`);
  const item = (await response.json()).response?.publishedfiledetails?.[0];
  if (!item || item.result !== 1) throw new Error(`Steam has no public details for item ${workshopId}`);
  return { title: item.title, description: item.description ?? '', previewUrl: item.preview_url ?? '', updated: item.time_updated, tags: (item.tags ?? []).map((entry) => entry.tag) };
}

export async function fetchImageDigest(url, fetchImpl = fetch) {
  const response = await fetchImpl(url, { signal: AbortSignal.timeout(TIMEOUT_MS) });
  if (!response.ok) throw new Error(`the preview image answered ${response.status}`);
  return digest(Buffer.from(await response.arrayBuffer()));
}
