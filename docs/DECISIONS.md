# Quyết định đã khóa

Status: LOCKED DERIVED VIEW
Canonical authority: [`PROJECT_CONTRACT.json`](PROJECT_CONTRACT.json)

1. `PROJECT_CONTRACT.json` và `app-contract.json` có quyền hạn cao hơn Markdown.
2. Hai writer giữ ownership độc lập nhưng phải chạy integration canary thật khoảng phút 40-50.
3. Canary thất bại đóng băng phạm vi mới; không chờ đến full integration mới sửa contract drift.
4. AITC Lavish là binary đã pin và local-only; không `npx`, cloud sharing hoặc remote asset.
5. Codex chạy tại gốc official repo; thay đổi sản phẩm chỉ nằm dưới `chung-khao/**`.
6. Push success không phải AI Log proof. Final gate cần HTTP 202 và readback đúng session.
7. Concurrency đọc live từ `/key/info`; DRILL mặc định 2, OFFICIAL mặc định 6, luôn chừa headroom.
8. Catalog/model existence không chứng minh Codex compatibility. Route cần model + endpoint + harness + tool-call smoke + provider proof.
9. Hai writer và một reviewer chỉ đọc vẫn là giới hạn ownership, độc lập với request concurrency của key.
