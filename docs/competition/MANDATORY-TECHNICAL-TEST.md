# Mandatory technical test: Gateway and AI Log

Status: execution complete; platform submission pending leader confirmation and CAPTCHA.

## Official timing

- Test opened: 2026-10-03 10:30 (platform time).
- Competition page closes: 2026-10-05 08:55.
- Submission deadline: 2026-10-05 09:00.
- Official documentation: <https://docs.thucchien.ai/docs/round-2>

The platform page and official repository remain authoritative if this record differs.

## Security rules

- Use only the two team-specific credentials supplied by the organizer: one Gateway credential and one AI Log credential.
- Never put credentials, passwords, PII, or `.env` content in AI prompts, commits, screenshots, issue text, or chat.
- Store credentials only in ignored local `.env` files and mask them in screenshots.
- Treat a credential pasted into any AI conversation as exposed and ask the organizer whether it must be rotated.
- The test credentials expire after the test deadline; official competition credentials will be issued separately.

## Required workflow and acceptance

1. Open the test page and record the submission deadline.
2. Call `GET https://api.thucchien.ai/key/info` with the team Gateway credential.
3. Call `POST https://api.thucchien.ai/chat/completions` with a low-cost assigned model.
4. Acceptance for both Gateway calls: HTTP 200; the chat response is present at `choices[0].message.content`.
5. Install the organizer hooks with `scripts/setup_hooks.ps1` on Windows or `scripts/setup_hooks.sh` elsewhere.
6. Generate one genuine prompt in a supported AI tool, run `python scripts/submit_log.py`, and require `202 Accepted`.
7. Call `GET https://live.thucchien.ai/api/ingest/entries`; require the genuine event, timestamp, repository, member identifier, and model.
8. Each member creates only their own check-in file under `chung-khao/`, stages only `chung-khao/`, commits with their own Git identity, and pushes with their own GitHub account.
9. Capture the four organizer-required screenshots and submit before the deadline.
10. For network errors, HTTP 401, or HTTP 403, contact the organizer on Discord with the failed step and status code, never the credential.

## Task-specific Git exception

The organizer explicitly requires each member to push the check-in directly to the official team repository's `main` branch. For this test only, that instruction overrides the harness branch-and-PR policy. The pushes must be sequential, small, and limited to `chung-khao/`; member Git identity, SSH account, clean status, and current `origin/main` must be verified before and after each push.

This exception does not apply to ordinary competition development or to this harness.

## Execution record

Verified on 2026-10-04:

- Gateway `/key/info`: HTTP 200.
- Gateway `/chat/completions`: HTTP 200 using `deepseek-flash`; content returned.
- AI Log submission: one genuine Codex prompt event and its genuine stop event each returned 202.
- AI Log retrieval: HTTP 200; server returned the prompt/stop events with timestamp, team repository, `deepseek-flash`, and the leader Git identity.
- Three member check-ins are present on the official repository `main` branch:
  - Bùi Minh Cường: `8f4e73f`
  - Nguyễn Đoàn Nhật Minh: `d0c09d1`
  - Bùi Hoàng Long: `dc0609b`
- All three isolated official-repository clones were synchronized cleanly to `dc0609b` after the pushes.

## Evidence checklist

- [x] Evidence window prepared for screenshot 1: `/key/info` HTTP 200 and `/chat/completions` HTTP 200.
- [x] Evidence window prepared for screenshot 2: `submit_log.py` returned 202.
- [x] Evidence window prepared for screenshot 3: server GET returned the genuine Codex events.
- [x] Official GitHub `chung-khao/` page opened for screenshot 4; three member files and commits verified through GitHub API.
- [ ] Leader confirms the four screenshots are readable, correctly cropped, and contain no credential.
- [ ] Leader completes the platform CAPTCHA/security confirmation.
- [ ] Submission receipt/status is captured and verified before the deadline.

## Submission fields

Suggested values:

- Title: `NAVIN Research - TEST Gateway, AI Log và Git Check-in`
- Description: `Đã kiểm tra Gateway, AI Log và quyền push của ba thành viên theo đúng hướng dẫn bài test kỹ thuật bắt buộc.`
- Source link: <https://github.com/ai-thuc-chien/aitc2026-team-918-navin-research/tree/main/chung-khao>
- Judge note: `Gateway và AI Log đã xác nhận HTTP 200/202; server đã trả về log thực; ba thành viên đã push file check-in riêng bằng đúng tài khoản.`

Do not claim the platform submission is complete until its receipt or submitted state is visible.
