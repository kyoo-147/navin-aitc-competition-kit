# Luồng vận hành cuộc thi

Status: LOCKED DERIVED VIEW
Canonical authority: [`PROJECT_CONTRACT.json`](PROJECT_CONTRACT.json)
Interactive Lavish: [`../artifacts/ux-flow.html`](../artifacts/ux-flow.html)

## Trước khi gọi mô hình

Captain xác nhận OFFICIAL hay DRILL, mở process tại gốc repo, kiểm tra origin, hooks, Gateway, budget, giới hạn song song live và route canary. Bất kỳ gate nào fail đều chặn model work.

## Chốt sản phẩm

Spec Broker cấu trúc đề bài. Ba scout chỉ đọc điều tra yêu cầu, kỹ thuật và trải nghiệm. Captain trình bày Human Brief cùng đúng hai artifact Lavish local-only. Sau khi anh duyệt, Captain sinh hai JSON authority, năm Markdown views và `PROJECT_LOCK.json`, rồi tạo lock commit.

## Xây và tích hợp sớm

FE và BE bắt đầu trong hai worktree riêng từ cùng lock/base commit. Mỗi lane test độc lập theo `app-contract.json`. Khoảng phút 40-50, Captain tích hợp một lát cắt thật. Nếu DTO, state, error shape, async flow, auth hoặc endpoint lệch, dừng mở rộng và sửa lát cắt trước. Khi canary pass, hai lane tiếp tục phần còn lại rồi Captain chạy full integration và E2E.

## Rà soát và giao bài

Reviewer khóa một fixed point rồi rà riêng Spec, Standards/Engineering và BTC Provenance. Sau deploy và runtime smoke, Captain push và xác minh remote SHA. Tiếp theo gửi AI Log, yêu cầu HTTP 202 và GET readback có `UserPromptSubmit` cùng `Stop` cho đúng session hiện tại. Chỉ sau đó mới được nộp bài và lưu biên nhận.
