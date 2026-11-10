# autocad-kien-truc

Skill cho Claude Code: vẽ bản vẽ kiến trúc và kết cấu trong AutoCAD (qua MCP `autocad-mcp`) theo template **Kien truc Arch.dwt** — đúng layer `G-*`, nét/lineweight, cỡ chữ, dim style `A3-N` theo tỷ lệ, dùng block nội thất/cửa/ký hiệu có sẵn.

## Nội dung

```
autocad-kien-truc/
├── SKILL.md      # quy trình, bảng layer, chuẩn dim/chữ, quy tắc bố trí
├── blocks.md     # danh mục block của template
├── helpers.lsp   # hàm LISP hỗ trợ (kt:walls, kt:axis, kt:dim, kt:cutdim...)
└── template/
    └── Kien truc Arch.dwt
```

## Yêu cầu

- AutoCAD 2025 (Windows) và MCP server `autocad-mcp` đã cài, Command Line đang hiện.
- Claude Code.

## Cài đặt

1. Copy thư mục `autocad-kien-truc/` vào `~/.claude/skills/` (dùng cho mọi dự án) hoặc `<dự án>/.claude/skills/`.
2. Copy `template/Kien truc Arch.dwt` vào thư mục Template của AutoCAD (`%LOCALAPPDATA%\Autodesk\AutoCAD 2025\R25.0\enu\Template\`).
3. Trong `SKILL.md`, mục 0, sửa đường dẫn nạp `helpers.lsp` cho đúng máy bạn.
4. Mở bản vẽ từ template, **Save As .dwg** (MCP chỉ nhận cửa sổ `.dwg`), rồi yêu cầu Claude vẽ.

## Quy tắc chính

- Chỉ dùng layer/block/style có sẵn trong template, không tạo mới.
- Tường chạy suốt qua cột, nét bao tường layer `G-Cat`, hatch layer `G-Hatch`.
- Dim 3 lớp, khoảng cách đều, luôn cắt chân dim, không đè chi tiết; nhịp trục ≤ 5500.

## Giấy phép

MIT (xem `LICENSE`). Template và block do tác giả tự tạo; dùng và chỉnh sửa tự do.
