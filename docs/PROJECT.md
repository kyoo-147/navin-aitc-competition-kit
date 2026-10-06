# Portable Competition Kit

Status: LOCKED DERIVED VIEW
Canonical authority: [`PROJECT_CONTRACT.json`](PROJECT_CONTRACT.json)
Boundary authority: [`../contracts/app-contract.json`](../contracts/app-contract.json)

## Goal

Cho phép leader và đồng đội clone một repo private, tái tạo an toàn cấu hình Codex/Orca trên Windows, rồi vận hành bài thi theo hợp đồng rõ ràng và bằng chứng fail-closed.

## Phạm vi bắt buộc

Kit đóng gói profile, skills, wrappers, templates, manifests, bootstrap, doctor, rollback và competition gates nhưng không chứa secret hay private runtime state. Trong chế độ chính thức, process AI chạy tại gốc repo organizer, còn mọi file do đội tạo nằm dưới `chung-khao/**`.

Sau khi anh duyệt đúng hai artifact Lavish, Captain khóa `docs/PROJECT_CONTRACT.json` và `contracts/app-contract.json`. Frontend và backend làm trong hai worktree riêng, gặp nhau bằng một lát cắt chạy thật khoảng phút 40-50, sau đó mới tiếp tục phần còn lại.

## Không thuộc phạm vi

Không copy raw user homes, auth, sessions, lịch sử, browser data, logs, SQLite state hoặc caches. Không tự nhập secret, đổi provider, dùng remote Lavish asset, hoặc coi push thành công là AI Log đã xác minh.

## Chấp nhận

Doctor và preflight phải chặn sai repo root, thiếu origin hoặc thiếu hook. Route chỉ hợp lệ khi đúng model, endpoint, harness và tool-call smoke. Final gate chỉ pass sau deploy, push, AI Log HTTP 202 và BTC readback đúng phiên Codex hiện tại.
