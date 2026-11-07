# Kwania TV Cloud (Cloudflare starter)

This is a cloud-backed synchronized playlist TV station scaffold:
- Static public TV website
- Admin password login
- Direct browser-to-R2 MP4 uploads using temporary presigned PUT URLs
- D1 programme catalogue and playlist ordering
- Automatic playlist repeat based on a shared broadcast clock
- All viewers calculate the same current programme and playback offset
- Programme guide and next-up panel
- Admin reorder, delete, upload, and reset broadcast clock

## Important: what “24/7 live” means here
This build synchronizes viewers to the same scheduled MP4 playlist and shared clock. It is not a server-side transcoded HLS live channel. It does not generate one continuous broadcast stream. A true HLS channel requires a continuously running playout/transcoding service and HLS packaging. This browser-based synchronized playlist is the lower-cost static-video option and does not require your phone to stay on.

## 1. Create Cloudflare resources
In Cloudflare dashboard:
1. Create an R2 bucket named `kwania-tv-media`.
2. Create a D1 database named `kwania-tv-db`.
3. Run `schema.sql` in the D1 console.
4. Create R2 S3 API credentials with object read/write permissions for this bucket. Keep the secret private.
5. Connect a custom domain such as `media.YOURDOMAIN.com` to the R2 bucket (R2 > bucket > Settings > Custom Domains). This makes uploaded MP4s publicly readable by viewers. Do not use `r2.dev` for production; Cloudflare documents it as development-only / rate-limited.
6. In R2 bucket CORS settings, allow your Pages site origin and methods `GET`, `HEAD`, `PUT`; allow headers `Content-Type`, `Range`; expose `ETag`, `Content-Length`, `Content-Range`, `Accept-Ranges`. Set a suitable max age.

## 2. Configure Worker
Edit `wrangler.toml`:
- Replace `FRONTEND_ORIGIN` with your Cloudflare Pages website URL.
- Replace `MEDIA_BASE_URL` with the R2 custom domain.
- Replace `R2_ACCOUNT_ID`.
- Replace `database_id` with the D1 database ID from Cloudflare.
- Ensure bucket name matches.

From a terminal in this folder:
```bash
npm install
npx wrangler secret put ADMIN_PASSWORD
npx wrangler secret put ADMIN_SECRET
npx wrangler secret put R2_ACCESS_KEY_ID
npx wrangler secret put R2_SECRET_ACCESS_KEY
npm run deploy
```
Use a long, unique ADMIN_PASSWORD. ADMIN_SECRET must be a different long random secret (32+ characters). R2 keys must never be placed in frontend code or GitHub source.

## 3. Connect the website to Worker
After deploying, copy the Worker URL (for example `https://kwania-tv-api.YOURSUBDOMAIN.workers.dev`).
In `public/index.html`, replace:
`https://YOUR-WORKER.workers.dev`
with your real Worker URL.

## 4. Deploy the website
Upload the contents of the `public` folder to your GitHub repository and connect it to Cloudflare Pages. Build command: leave blank. Build output directory: `public` (if the repository root contains this project). If you upload only the contents of `public` to the repository root, use `/` as the output directory.

## 5. Test
- Open the Pages URL and check that the player says no programmes are uploaded.
- Open Admin, enter your ADMIN_PASSWORD.
- Upload a short MP4.
- Open the public site on another phone/browser. It should show the same programme and playback position.
- Add more videos, change their order, and check the guide.
- Use Start/reset broadcast clock after finishing the playlist order.

## Security and production notes
- Keep Worker secrets out of source code and public GitHub repositories.
- This starter uses a single administrator password. Add stronger account management/rate limiting before opening admin access widely.
- The media custom domain is public: anyone with a media URL can play/download the MP4. Do not upload copyrighted content unless you have distribution rights.
- Large files: this starter uses a single presigned PUT. Cloudflare R2 supports multipart uploads for large videos; implement multipart/resumable upload if you need very large files or unreliable mobile connections.
- Video formats/codecs matter. H.264 video + AAC audio in MP4 offers broad browser compatibility.
- Cloudflare R2 charges may apply for storage and operations; check current Cloudflare pricing. R2 has no egress bandwidth charge according to its pricing model, but storage and operations are not unlimited free.
