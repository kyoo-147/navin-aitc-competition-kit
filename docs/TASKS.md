# Nhiệm vụ vận hành đã khóa

Status: LOCKED DERIVED VIEW
Canonical authority: [`PROJECT_CONTRACT.json`](PROJECT_CONTRACT.json)

1. Chạy doctor/preflight từ gốc official repo và xác minh origin cùng AI hooks.
2. Đọc `/key/info`, budget và chọn giới hạn lượt gọi còn headroom.
3. Chạy tool-call canary cho đúng model + endpoint + harness; lưu provider/session evidence.
4. Hoàn thành Spec Broker, Human Brief và đúng hai Lavish artifacts local-only.
5. Khóa canonical contract, boundary contract, Markdown views và Lavish hashes.
6. Tạo tối đa hai worktree cho hai subsystem độc lập có giá trị cao nhất từ cùng lock/base commit.
7. Chạy real integration canary khoảng phút 40-50 và commit evidence.
8. Hoàn tất hai lane, full integration, E2E và ba review độc lập.
9. Deploy và smoke, push và xác minh remote SHA.
10. Submit AI Log, yêu cầu HTTP 202, GET readback đúng session, rồi mới final submit.
