# Kiến trúc Competition Kit

Status: LOCKED DERIVED VIEW
Canonical authority: [`PROJECT_CONTRACT.json`](PROJECT_CONTRACT.json)
Architecture Lavish: [`../artifacts/architecture.html`](../artifacts/architecture.html)

## Quyền hạn

`docs/PROJECT_CONTRACT.json` là nguồn sự thật máy đọc cho yêu cầu, phạm vi, kiến trúc, quyết định, acceptance và tasks. `contracts/app-contract.json` là ranh giới FE/BE cho routes, requests, responses, states và errors. Năm Markdown là bản trình bày để con người đọc, không có quyền ghi đè hai JSON này.

## Luồng xây dựng

Human Lock tạo một lock commit chứa hash của hai contract, năm Markdown và hai Lavish artifacts. Backend và frontend làm độc lập trong worktree, nhưng khoảng phút 40-50 phải chứng minh một lát cắt thật: giao diện thật gọi endpoint thật, dịch vụ hoặc AI thật xử lý khi cần, response thật quay về và giao diện render kết quả. Canary thất bại sẽ đóng băng phạm vi mới cho đến khi sửa xong.

## Runtime chính thức

Codex process chạy tại gốc official repository để organizer AI Log hooks hoạt động. Quyền sửa của Captain và workers vẫn giới hạn trong `chung-khao/**`. `doctor.ps1` và `preflight.ps1` kiểm tra Git top-level, origin và đủ `UserPromptSubmit`, `PostToolUse`, `Stop` hooks.

## Lavish

AITC dùng `lavish-axi` 0.1.63 đã cài sẵn. Artifact chỉ có HTML, CSS/JS inline hoặc local, system font và local SVG. Cấm `npx`, share/publish cloud, remote asset, Tailwind CDN, Google Fonts và remote JavaScript.

## Routing và giao bài

Route hợp lệ là một tuple đã kiểm chứng: model + endpoint + harness + tool-call smoke + rollout provider proof. Giới hạn lượt gọi đọc live từ `/key/info`; DRILL mặc định 2, OFFICIAL mặc định 6 và luôn chừa headroom. Deploy, push, AI Log submit, same-session readback và final submission là các gate độc lập.
