---
name: autocad-kien-truc
description: Vẽ bản vẽ kiến trúc và kết cấu trong AutoCAD (qua MCP autocad-mcp) theo đúng tiêu chuẩn của template "Kien truc Arch.dwt" — đúng layer (G-*), nét/lineweight, cỡ chữ, dim style A3-xx theo tỷ lệ, và dùng block nội thất / cửa / ký hiệu có sẵn. Dùng khi người dùng yêu cầu vẽ mặt bằng, mặt cắt, mặt đứng, bố trí nội thất, mặt bằng kết cấu, bố trí thép, trục, cửa, ghi kích thước, ghi chú trong AutoCAD.
---

# Vẽ kiến trúc / kết cấu theo template "Kien truc Arch.dwt"

Template gốc: `C:\Users\Tuanmetal32\AppData\Local\Autodesk\AutoCAD 2025\R25.0\enu\Template\Kien truc Arch.dwt`
Đơn vị: **mm** (INSUNITS=4), vẽ model space **tỷ lệ 1:1** (tường 220 thì vẽ 220).
Danh mục block chi tiết: xem [blocks.md](blocks.md). Đoạn LISP hỗ trợ: [helpers.lsp](helpers.lsp).

## 0. Quy trình bắt buộc

1. `system status` → nếu lỗi/AutoCAD vừa khởi động lại thì `system init`. Nếu vẫn lỗi, xem mục 7 (sự cố kết nối).
2. `drawing info` → kiểm tra bản vẽ hiện tại có các layer `G-*`. Nếu **không có**, mở bản vẽ mới từ template
   (LISP: `(command "_.NEW" "<đường dẫn template>")`) hoặc hỏi người dùng — **không tự tạo layer lạ**.
3. Hỏi/chốt **tỷ lệ bản vẽ 1:N** (mặc định mặt bằng 1:100, chi tiết 1:20–1:50). Mọi cỡ chữ, dim style, scale ký hiệu suy ra từ N (mục 3).
4. Nạp helper (một lần mỗi phiên AutoCAD): `system execute_lisp` với
   `(load "D:/01. JOB/01. Mr. Tuan/Other/Training/Claude/.claude/skills/autocad-kien-truc/helpers.lsp")` → trả về "kt helpers loaded".
   Sau đó gọi `(kt:scale N)` để đặt k, dim style A3-N và LTSCALE.
5. Vẽ theo thứ tự: trục → cột/vách → tường → cửa → nội thất/thiết bị → hatch → kích thước → text/ký hiệu.
6. Mỗi đối tượng **phải nằm đúng layer** (bảng mục 1). Màu, linetype, lineweight để **ByLayer** — không gán đè.
7. Kết thúc: `view zoom_extents` + `view get_screenshot` để kiểm tra, rồi báo người dùng. Chỉ `save` khi được yêu cầu.

## 1. Bảng layer (giá trị thực trong DWG)

### Kiến trúc
| Layer | Màu | Linetype | LW (mm) | Dùng cho |
|---|---|---|---|---|
| G-Cat | 4 | Continuous | 0.40 | **Nét bao tường bị cắt trên mặt bằng (mặc định cho mọi tường)**, đường bao vật bị cắt, nền đất, mặt cắt |
| G-Tuong | 31 | Continuous | 0.40 | Không dùng cho nét bao tường (người dùng chuẩn hoá tường về G-Cat); chỉ dùng khi được yêu cầu |
| G-Betong | 6 | Continuous | 0.40 | Cột, dầm, sàn BTCT bị cắt |
| G-Thay | 7 | Continuous | 0.20 | Nét thấy (bậc thang, gờ, mép sàn, đường nhìn thấy) |
| G-Manh | 125 | Continuous | 0.15 | Nét mảnh, chi tiết phụ |
| G-Nho | 144 | Continuous | 0.13 | Nét rất nhỏ (gạch ốp, lam, chi tiết nhỏ) |
| G-Khuat | 252 | DASHED2 | 0.20 | Nét khuất (dầm trên, mái đua, vật bị che) |
| G-Tim | 9 | CENTER2 | 0.15 | Trục định vị, đường tim |
| G-Cua | 34 | Continuous | 0.13 | Cửa đi, cửa sổ (block cửa) |
| G-Kinh | 154 | Continuous | 0.05 | Kính, vách kính |
| G-Noithat | 13 | Continuous | 0.13 | Nội thất, thiết bị vệ sinh, bếp, xe |
| G-Cay | 118 | Continuous | 0.05 | Cây xanh, cảnh quan |
| G-Hatch | 251 | Continuous | 0.05 | Mọi hatch (HPLAYER đã đặt = G-Hatch) |
| G-Dim | 9 | Continuous | 0.13 | Kích thước |
| G-Text | 3 | Continuous | 0.20 | Text, tên phòng, ký hiệu (cửa, cao độ, mặt cắt) |
| G-text 2 | 6 | Continuous | 0.20 | Text phụ (màu khác để phân biệt) |
| G-Khung | 7 | Continuous | 0.20 | Khung tên, khung bản vẽ |
| G-Others | 8 | Continuous | 0.13 | Khác |
| Defpoints | — | — | không in | Đường dựng, điểm phụ |

### Kết cấu
| Layer | Màu | Linetype | LW | Dùng cho |
|---|---|---|---|---|
| G-Bo1 | 30 | Continuous | 0.25 | Nét bao mặt bằng kết cấu, lỗ mở |
| G-Bo2 | 2 | Continuous | 0.25 | Nét thấy dầm trên MBKC, mặt cắt dầm, cột |
| G-Bo3 | 7 | HIDDEN | 0.25 | Khung mặt cắt, khung thống kê |
| G-Khuat dam | 7 | HIDDEN | 0.20 | Nét khuất dầm trên mặt bằng kết cấu |
| G-Steel1 | 1 | Continuous | 0.30 | Cốt thép chủ |
| G-Steel2 | 4 | Continuous | 0.30 | Thép đai, thép cấu tạo |
| G-Betong | 6 | Continuous | 0.40 | Đường bao bê tông bị cắt |
| G-Tim | 9 | CENTER2 | 0.15 | Trục |

Quy tắc phân nét: **cắt (0.40) > thấy (0.20) > mảnh (0.15) > nhỏ/nội thất (0.13) > hatch/kính/cây (0.05)**.
Không vẽ gì lên layer `0` trừ khi định nghĩa block.

## 2. Linetype scale

Linetype trong file là bản imperial (CENTER2 = 1.125, DASHED2/HIDDEN = 0.375 đơn vị/chu kỳ), PSLTSCALE=1, MSLTSCALE=1.
- In từ **model space** tỷ lệ 1:N → `LTSCALE = 10 × N` (1:100 → 1000; 1:50 → 500).
- In qua **layout/viewport** → giữ `LTSCALE = 10`, PSLTSCALE=1.
- **Đường tim trục (G-Tim): Linetype scale của đối tượng = 0.5** (dxf 48). `kt:axis` tự gán (biến `*kt-tim-lts*`). Trục vẽ tay thì phải tự gán 0.5.
- Các đối tượng khác không đổi linetype scale riêng trừ khi cần chỉnh cục bộ.

## 3. Chữ, kích thước và tỷ lệ

Hệ số tỷ lệ: **k = N / 100** (1:100 → k=1; 1:50 → 0.5; 1:200 → 2; 1:20 → 0.2).

### Text style (đã có trong template)
| Loại | Style | Cao chữ (model) = | Ví dụ |
|---|---|---|---|
| Tiêu đề bản vẽ | `Thang - Tieu De` | 400·k | "MẶT CẮT 1-1" |
| Chữ thường (tên phòng, ghi chú) | `Thang - Tieu De` | 220·k | "P.NGỦ", "P.KHÁCH" |
| Chữ trích dẫn | `Thang - Ghi chu` | 220·k | "Chi tiết bồn hoa…" |
| Ghi chú nhỏ / kết cấu | `Thang - Ghi chu` | 125·k | "Ø10a200", ghi chú thép |
| Tiêu đề nhóm lớn | `Thang - Tieu De` | 1000·k | Chỉ dùng cho bảng tra |

Font Unicode TTF → tiếng Việt có dấu viết trực tiếp được. Khi gửi qua LISP, nếu lỗi encoding dùng mã `\U+1EBE` (ví dụ `"B\\U+1EBEP"` = BẾP).

### Dim style
Dùng dim style **`A3-N`** đúng tỷ lệ bản vẽ (có A3-10, A3-15 … A3-210, bước 5). Các style giống nhau trừ DIMSCALE = N/100:
chữ dim 220 (×DIMSCALE), mũi tên `_ArchTick`, text style `Thang - Ghi chu`, layer `G-Dim`.
Trước khi ghi kích thước: `(setvar "DIMSTYLE" ...)` qua `(command "_.-DIMSTYLE" "_R" "A3-100")` và `CLAYER = G-Dim`.
Quy ước ghi kích thước mặt bằng: 3 lớp bên ngoài — (1) chi tiết cửa/tường (đoạn tường + lỗ mở, xem mục 5), (2) khoảng trục (mỗi nhịp ≤ 5500), (3) tổng — cách nhau ≈ 600·k, lớp trong cách mép tường ≈ 1000·k.

**Bắt buộc cắt chân dim sau khi ghi kích thước** (thuật toán lệnh `CD2` của người dùng, file `E:\Setup\Major\Autocad\Lisp\Lisp\CUTDIM.lsp`;
`c:cd2` cần chọn/pick tay nên không gọi được qua MCP → dùng `kt:cutdim`):
- Gom dim theo từng phía (trái / phải / trước / sau), mỗi phía gọi `(kt:cutdim (list e1 e2 ...) (list x y))` một lần.
- Điểm `(x y)` nằm trên đường cắt song song đường dim, **cách đường dim chuỗi (lớp trong) 286 về phía công trình**
  (theo bản mẫu; ví dụ phía trái, dim chuỗi ở x = X0−1250 → điểm cắt x = X0−964). Mọi chân dim của phía đó bắt đầu cùng trên đường này.
- `kt:dimchainx/y` trả về list ename → nối các list lại rồi đưa vào `kt:cutdim`.

### Ký hiệu (block chú thích)
Scale ký hiệu = **k** (template mẫu dùng 0.75–0.9 ứng với ~1:100 có chỉnh tay). Đặt trên layer `G-Text` (trục: `0` trong mẫu → nên đặt `G-Tim` hoặc `G-Text`).

## 4. Cách thao tác qua MCP

- **Vẽ hình học**: `entity create_line / create_polyline / create_rectangle / create_circle / create_arc` với tham số `layer` đúng bảng mục 1.
- **Text**: dùng `annotation create_text` cần set layer + style trước; ổn định nhất là LISP helper `(kt:text x y "nội dung" h "Thang - Tieu De" "G-Text")`.
- **Block**: `block insert` KHÔNG có tham số layer → dùng helper `(kt:ins "tên block" x y scale rot "G-Noithat")` hoặc `layer set_current` trước khi chèn.
- **Nội thất**: điểm chèn của block nội thất KHÔNG nằm ở góc (ví dụ giường đôi lệch ~500) → luôn dùng `(kt:insll name x y 1 rot lay)` (góc dưới-trái bbox đặt tại x,y) hoặc `(kt:insc ...)` (tâm bbox tại x,y), rồi kiểm tra `(kt:bbox e)` nằm trong lòng phòng (mép trong tường).
- **Block động (cửa, vách, ghế…)**: chỉnh tham số bằng `(kt:dyn ent "Distance" 900.0)` (tên tham số trong blocks.md).
- **Thuộc tính**: `(kt:att ent "DIMENSION" "900x2200")` hoặc `block update_attribute`.
- **Hatch**: `(kt:hatch ent "ANSI31" 20.0)`; tường gạch thường ANSI31, bê tông cắt `SOLID` hoặc `AR-CONC`, nền đất `EARTH`; layer luôn `G-Hatch`.
- **Tường**: luôn vẽ CẢ HỆ tường một lần bằng `(kt:walls ws cols T)`:
  - `ws` = list `(x1 y1 x2 y2 dày)` theo tim tường; chỗ cửa tách tường thành 2 đoạn.
  - `cols` = list ename đường bao cột (từ `kt:col`) để trừ khỏi tường, hoặc `nil`.
  - Đầu tường chạm tường khác (góc L, chữ T) tự kéo dài thêm nửa bề dày tường kia → **giao vuông góc, không khuyết góc L**.
  - Ra polyline kín layer **G-Cat** (mỗi khối 1 vòng, phòng kín có lỗ được hatch đúng) + hatch ANSI31 20·k.
  - **Không** vẽ từng đoạn bằng `kt:wall` rồi để chồng nhau: các đoạn dừng ở tim trục sẽ để hở ô vuông ½×½ bề dày ở góc L.
- **Cắt chân dim**: `(kt:cutdim list-ename (list x y))` — xem mục 3.
- **Cao độ**: `(kt:cos x y "-0.150")` — block `Coskhac` scale k, layer G-Text, thuộc tính thật là **`+24.000`**.
- `execute_lisp` trả về giá trị biểu thức cuối; với danh sách lớn hãy ghi ra file `C:/temp/*.txt` rồi đọc bằng Bash để tránh timeout.

## 5. Mẫu quy trình

### Mặt bằng kiến trúc — CHUẨN TRÌNH BÀY THEO BẢN MẪU CỦA NGƯỜI DÙNG (ưu tiên hơn mục 3)
Bản mẫu "01. Phuong an nha a Duong" (mặt bằng tầng 1, dim style A3-50). Giá trị dưới là kích thước thật trong model:

| Thành phần | Quy cách |
|---|---|
| Tên phòng | text h**132**, `Thang - Tieu De`, G-Text, căn giữa (Center), dạng `P.KHÁCH`, `P.NGỦ`, `P.BẾP + ĂN`, `P.WC1`… |
| Diện tích | dòng ngay dưới tên (baseline thấp hơn 181), h**100**, dạng `DT 15.2M2` (1 số lẻ, m², tính thông thủy) → `kt:room` |
| Tiêu đề | `MẶT BẰNG TẦNG 1` h**200**, căn giữa, cách bóng trục dưới cùng ≈1460; không ghi dòng tỷ lệ |
| Số bậc thang | đánh số **lẻ** 1,3,5,… (mỗi số ở tâm 2 bậc, h**100**, căn giữa, cạnh mũi tên đi lên ~110) **theo số bậc thực** (tầng 1 tối ưu 21 bậc → 1…21, xem skill `Soat_ban_ve_kien_truc` A3); không dùng chữ "LÊN" → `kt:stairodd2` |
| Bậc thang | chia **2 phần**: một phần nét **đậm** (G-Thay, vế thấy/bị cắt), một phần nét **mảnh** (G-Manh), ngăn bởi đường gãy khúc |
| Thang và tường | Thang **không xâm lấn** tường: mép ngoài thang (kể cả chiếu nghỉ) tựa đúng **mặt tường**, không vượt qua mặt tường vào lõi tường (tường 220 chạy dọc thang vẽ thêm khi cần). Mọi nét thang (bậc, nét gãy, mũi tên, số bậc) dời **cùng một vector**; chọn bằng cửa sổ **W** (bao kín) để không kéo theo tường. Kiểm tra: không còn nét thừa chồng lên tường hoặc kéo dài quá bậc cuối |
| Tường qua cột | nét tường (G-Cat) **chạy suốt qua cột**, không ngắt tại cột → gọi `kt:walls ws nil T` (cols = nil, không trừ cột); cột vẽ đè lên |
| Ký hiệu trục | block `ky hieu truc` scale **0.5**, layer **G-Tim**, ở **cả hai đầu** trục; tâm bóng cách đầu đường tim 172 → `kt:axis` |
| Đường tim | G-Tim, linetype scale 0.5, dừng cách đường dim ngoài cùng **300** (mép bóng trục cách dim ≈ 300) |
| Cao độ | `Coskhac` scale **0.55** → `kt:cos` |
| Dim | style **A3-50**, override **DIMFXLON=1, DIMFXL=500** (chân dim cố định) → `kt:dim` tự gán (`*kt-dimfxl*`) |
| Dim 2 lớp mỗi phía | lớp 1 (chuỗi): mép tường ngoài → các trục → mép tường ngoài, cách mép tường **1140**; lớp 2 (tổng): mép ngoài → mép ngoài, cách lớp 1 **250**. Chân dim cắt bằng `kt:cutdim` tại điểm cách đường dim chuỗi 286 về phía công trình |
| Lớp dim thứ 3 — đoạn tường (bổ sung 2026-11-10) | Sát công trình nhất, **trong** lớp dim trục: ghi chiều dài từng đoạn tường và từng lỗ mở (cửa, cửa sổ) dọc mép ngoài tường, tính từ mép ngoài đến mép ngoài (kể cả phần tường nhô 110 ở góc). Khoảng cách đường dim đến mép tường **không giới hạn cố định**, chọn sao cho chữ dim rõ và không chạm chân dim lớp trục. Chỉ ghi phía có lỗ mở; phía tường liền không có lỗ mở thì bỏ (đã có dim tổng). Tạo bằng `vla-AddDimAligned` (style A3-50, layer G-Dim). **Khoảng cách giữa các lớp dim phải đều nhau** (từ mép tường đến lớp 3, từ lớp 3 đến lớp 2, từ lớp 2 đến lớp 1 bằng nhau ở cả bốn phía; chỉnh lại các lớp cũ nếu cần). **Luôn cắt chân dim** cho mọi lớp, kể cả lớp này, để các chân dim bắt đầu thẳng hàng trên một đường cắt |

Thứ tự vẽ:
1. Trục: `kt:axis` cho từng trục (số 1,2,3… theo chiều dài nhà, chữ A,B… theo chiều ngang).
2. Cột: `kt:col` (G-Betong + SOLID). Tường chạy suốt qua cột: truyền `cols = nil` vào `kt:walls`.
3. Tường: `kt:walls` cho toàn bộ tường (220 / 110) → nét bao G-Cat, góc giao vuông, hatch ANSI31 20·k.
4. Cửa: chèn block cửa trên G-Cua (`cd1`, `cd2`, `cd4`, `Cua 4 canh`, `cs2`, `cs4`…), chỉnh `Distance` = khẩu độ.
5. Nội thất / thiết bị: block trong blocks.md, layer G-Noithat (cây: G-Cay).
6. Thang: chia 2 phần, phần đậm G-Thay, phần mảnh G-Manh; vế bị che G-Khuat; mũi tên G-Manh; số bậc lẻ 1,3,5… theo số bậc thực bằng `kt:stairodd2`. Mặt bằng **mái không vẽ cột**.
7. Tên phòng + diện tích: `kt:room x y "P.KH\U+00C1CH" 23.1`; tránh đè lên số bậc, thiết bị.
8. **Cao độ: mỗi khu vực một `kt:cos` và PHẢI điền giá trị**. Mặc định nếu người dùng chưa cho:
   phòng khách/phòng ở `+0.000`, sân/hè `-0.150`, WC/khu rửa/lô gia `-0.050`; hỏi lại nếu nhà có cốt khác.
9. Dim: `(command "_.-DIMSTYLE" "_R" "A3-50")` rồi 2 lớp mỗi phía, sau đó `kt:cutdim` từng phía.
10. Tiêu đề h200 bằng `kt:tc`.

### Quy tắc dim không đè chi tiết
- **Đường dim, chân dim và chữ dim không được đè lên chi tiết kiến trúc** (thềm, bậc cấp, cánh cửa mở ra ngoài, ban công, lam, tường nhô, ký hiệu…).
- Kiểm tra mỗi phía sau khi ghi dim (zoom sát hoặc so bbox các đối tượng với đường dim). Nếu có xung đột: **giãn cách các lớp dim ra xa** đối tượng bị đè, tăng đều cho cả bộ lớp dim của phía đó để khoảng cách giữa các lớp vẫn bằng nhau.
- Khi giãn dim thì **dời cả đường tim trục (đầu đường tim) và ký hiệu trục (bóng trục)** ra xa tương ứng, giữ khoảng cách bóng trục – đường dim tổng như chuẩn; dời cùng phía cho tất cả trục. Cắt lại chân dim theo vị trí mới.

### Quy tắc bố trí bổ sung (nhà phố 5×15, 2026-11-10)
- **Khoảng cách lưới trục: mỗi nhịp ≤ 5500** (tim–tim). Nhịp lớn hơn phải chèn thêm trục ở vị trí hợp lý (ví dụ đầu cầu thang, nơi có tường hai bên đặc để đặt cột). **Không tạo trục phụ** (không dùng `1'`…): trục thêm vào là trục chính, sau đó **đánh số lại liền mạch từ 1 đến hết** theo chiều dài nhà (sửa attribute các bóng trục cũ). Đủ bộ cho trục mới: đường tim G-Tim (copy trục gần nhất, giữ linetype scale 0.5), hai bóng trục (`ky hieu truc`, đổi attribute), cột G-Betong + SOLID ở giao với tường, và **tách lại dim chuỗi** (dim 7000 → 4500 + 2500), dim tổng giữ nguyên.
- **Nội thất phòng khách (sofa – tivi):** tivi và bộ sofa đặt đối xứng quanh **một trục chung**; cụm chữ phòng (tên + diện tích) và **cao độ** đặt **trên đúng trục đó**, ở giữa khoảng trống giữa sofa và tivi, không đè lên bàn/sofa/tivi. Thứ tự từ trên xuống: tên phòng, diện tích (cách 180), cao độ. Sofa kê sát tường trục; kệ tivi mỏng 300 sát tường đối diện.
- **Cửa chính mở ra ngoài** (cánh quay ra phía thềm). Lật cửa bằng mirror quanh **tim tường** rồi xoá bản gốc; sau đó kiểm tra bbox đúng mặt tường phía ngoài.
- **Nhà vệ sinh:** cửa mở áp về tường vách gần nhất, có **bạo cửa 110**; thiết bị dồn về tường đối diện cửa; vòi lavabo phải sát tường (lật lại nếu thấy ngược). Thứ tự thiết bị và bề rộng tối thiểu: theo skill `Soat_ban_ve_kien_truc` (C3, C4).
- **Nhà phố luôn vẽ mặt bằng nằm ngang khổ giấy** (người dùng chốt 2026-11-11): chiều dài nhà theo phương X. Quy trình xoay (khi đã vẽ đứng): chọn toàn bộ nội dung mặt bằng (kể cả dim, trục, ký hiệu, tiêu đề), `ROTATE` **90° ngược chiều kim đồng hồ** quanh tâm mặt bằng → **mặt tiền ở bên phải**, trục số chạy 4,3,2,1 từ trái sang phải, trục chữ A ở dưới, B ở trên (mặc định; đổi chiều nếu người dùng yêu cầu). Sau xoay **dựng lại**:
  - TEXT rotation 0; `Coskhac` và `ky hieu truc` rotation 0 (thuộc tính cũng rotation 0).
  - Cặp tên phòng/diện tích: xoay làm hai dòng nằm cạnh nhau, đưa về **tên trên, diện tích dưới** cùng một tâm (tên cao +40, diện tích −141 so với tâm nhãn).
  - Cao độ: dời về **dưới nhãn phòng 730**.
  - Ký hiệu cắt `KHcat2`: giữ góc xoay (mũi tên chỉ đúng hướng nhìn), đặt lại vị trí chữ trong vòng tròn (số ở trên, `KT-xx` ở dưới, rotation 0).
  - Tiêu đề (vd. `MẶT BẰNG TẦNG 1`, h200) đặt **dưới** mặt bằng, căn giữa, cách tâm bóng trục dưới cùng ≈ 1460.
  - Nhiều mặt bằng xếp thành một **hàng ngang**, tâm cách nhau ≥ 30000 để không đè nhau.

### Quy tắc dim bổ sung (người dùng chốt 2026-11-11, nhà phố 4,66×12 — ưu tiên hơn các số 250/1140 ở bảng trên)
Gọi tên lớp dim từ ngoài vào: **lớp ngoài cùng = tổng**, **lớp giữa = trục**, **lớp trong = đoạn tường/lỗ mở**. Dim style `A3-50`.
- **Khoảng cách giữa các đường dim = 220.** Vị trí cố định cho mọi phía, tính từ mép tường (hoặc từ mép phần nhô ra ngoài tường như bậc thềm, ban công): lớp trong **450**, lớp giữa **670**, lớp ngoài cùng **890**. Phía không có lớp trong thì để trống chỗ đó, các lớp còn lại không dịch vào.
- **Lớp trục bổ sung dim 110** từ trục ra mép ngoài cột/tường ở hai đầu, cả 4 phía. Chuỗi mẫu: `0, 110, trục2, trục3, …, dài−110, dài` (trục tim cách mép ngoài 110).
- **Lớp ngoài cùng bổ sung dim phần nhô ra** (từng bậc thềm tới bậc ngoài cùng, ban công đua) nằm **cùng đường** với dim tổng, ở phía hai đầu nhà nơi có phần nhô ra. Chuỗi mẫu: `-600, -300, 0, 12000` (thềm 2 bậc × 300), ban công đua 1200: `-1200, 0, 12000`.
- Phía có phần nhô ra (thềm/ban công): các lớp dim đo từ **mép nhô ra ngoài cùng**, không đè lên thềm/ban công.
- **Chân dim:** vẫn có cố định (DIMFXLON=1) nhưng **chiều dài từng lớp khác nhau** = khoảng cách từ đường dim đến đường cắt. Đường cắt cách mép tường **164** (= 450 − 286): lớp trong dài **286**, lớp giữa **506**, lớp ngoài cùng **726**. Sau khi tạo dim: `vla-put-ExtLineFixedLen` từng dim theo bảng này rồi `kt:cutdim` theo từng phía (điểm cắt cách mép tường 164).
- **Trục/bóng trục theo dim mới:** đầu đường tim cách đường dim ngoài cùng **300** (sửa 2026-11-11, trước là 170), bóng trục cách đầu 172 (`kt:axis`) → mép bóng trục cách dim ≈ 300; đầu trục lệch từ mép nhô ra: dưới `yb−890−300`, trên `15000+890+300`, trái `−890−300`, phải `5000+890+300`; tiêu đề bản vẽ (h200, căn giữa) cách tâm bóng trục dưới cùng ≈ 1460. Khi dời lớp dim thì dời đúng đường tim, bóng trục và tiêu đề theo.
- Khi vẽ lại dim: xoá **chỉ** DIMENSION, đường tim G-Tim, bóng trục và tiêu đề h200 trong vùng toạ độ của bản vẽ (kèm điều kiện toạ độ, xem “Lưu ý thao tác”), không đụng nội dung khác.

### Quy tắc vẽ tường, cửa sổ, cửa đi bổ sung (2026-11-11)
- **Tường:** tim tường ngoài cách mép ngoài 110 (tường 220), vách ngăn 110 theo tim; trục định vị lấy theo tim. Vẽ cả hệ bằng một lần `kt:walls` (cols = nil). **Ô cửa là khoảng hở giữa các đoạn tường** trong danh sách `ws`: tách đoạn tường tại mép ô cửa, không vẽ tường rồi cắt. Cột 220×220 (`kt:col`) đặt ở giao trục với tường ngoài.
- **Dạ cửa:** tại **mọi ô cửa sổ** vẽ thêm **hai nét mảnh (`G-Manh`) nối hai đầu tường** qua ô cửa, một nét theo mặt trong và một nét theo mặt ngoài tường, để thể hiện dạ cửa. Cửa đi không vẽ dạ.
- **Cửa sổ `cs2`/`cs4`:** đặt `Distance1` = bề rộng ô cửa, **`Distance` luôn = 140** (đặt theo bề dày tường 220 thì bbox lệch và cửa nhô khỏi tường). Điểm chèn = góc trái dưới ô cửa, cao độ y = mặt trong tường + (dày tường − 140)/2 để khung nằm giữa bề dày tường.
- **Cửa đi `cd1`/`cd2`:** điểm chèn = đầu khung (jamb) tại **mặt tường phía cánh mở**; `Distance1` = bề dày tường; chiều mở: rot 0 mở +y, 90 mở −x, 180 mở −y, 270 mở +x (khi rot 90/270 điểm chèn là đầu mút tương ứng của ô cửa: rot 90 lấy mép dưới ô cửa, rot 270 lấy mép trên). `cd1`: ô cửa rộng = `Distance` + 100; `cd2`: ô cửa rộng = `Distance`. Cửa chính mở ra ngoài; cửa phòng luôn mở vào phòng. Cửa chính rộng tối thiểu 2150, nên 3300, dạng 4 cánh (`cd4`/`Cua 4 canh`) – xem `Soat_ban_ve_kien_truc` A2.
- Block động (cửa, cửa sổ) khi đổi tham số sẽ sinh block ẩn `*U…`: bình thường. Muốn chọn chúng bằng LISP thì lọc theo **layer** (`G-Cua`), không lọc theo tên block.
- **Thềm / ban công:** thềm vẽ `G-Thay`, ngoài mặt tiền, **mặt bậc rộng 300, cao 150**; ban công đua vẽ `G-Thay` + nét lan can `G-Manh` thụt vào 100; trên mặt bằng mái thể hiện ban công bằng nét `G-Khuat`.

### Quy tắc dim bổ sung (người dùng chốt 2026-11-11, nhà phố 4,66×12 — ưu tiên hơn các số 250/1140 ở bảng trên)
Gọi tên lớp dim từ ngoài vào: **lớp ngoài cùng = tổng**, **lớp giữa = trục**, **lớp trong = đoạn tường/lỗ mở**. Dim style `A3-50`.
- **Khoảng cách giữa các đường dim = 220.** Vị trí cố định cho mọi phía, tính từ mép tường (hoặc từ mép phần nhô ra ngoài tường như bậc thềm, ban công): lớp trong **450**, lớp giữa **670**, lớp ngoài cùng **890**. Phía không có lớp trong thì để trống chỗ đó, các lớp còn lại không dịch vào.
- **Lớp trục bổ sung dim 110** từ trục ra mép ngoài cột/tường ở hai đầu, cả 4 phía. Chuỗi mẫu: `0, 110, trục2, trục3, …, dài−110, dài` (trục tim cách mép ngoài 110).
- **Lớp ngoài cùng bổ sung dim phần nhô ra** (từng bậc thềm tới bậc ngoài cùng, ban công đua) nằm **cùng đường** với dim tổng, ở phía hai đầu nhà nơi có phần nhô ra. Chuỗi mẫu: `-1400, -700, 0, 12000` (thềm 2 bậc × 700), ban công đua 1200: `-1200, 0, 12000`.
- Phía có phần nhô ra (thềm/ban công): các lớp dim đo từ **mép nhô ra ngoài cùng**, không đè lên thềm/ban công.
- **Chân dim:** vẫn có cố định (DIMFXLON=1) nhưng **chiều dài từng lớp khác nhau** = khoảng cách từ đường dim đến đường cắt. Đường cắt cách mép tường **164** (= 450 − 286): lớp trong dài **286**, lớp giữa **506**, lớp ngoài cùng **726**. Sau khi tạo dim: `vla-put-ExtLineFixedLen` từng dim theo bảng này rồi `kt:cutdim` theo từng phía (điểm cắt cách mép tường 164).
- **Trục/bóng trục theo dim mới:** đầu đường tim cách đường dim ngoài cùng 170, bóng trục cách đầu 172 (`kt:axis`); tiêu đề bản vẽ (h200, căn giữa) cách tâm bóng trục dưới cùng ≈ 1460. Khi dời lớp dim thì dời đúng đường tim, bóng trục và tiêu đề theo.
- Khi vẽ lại dim: xoá **chỉ** DIMENSION, đường tim G-Tim, bóng trục và tiêu đề h200 trong vùng toạ độ của bản vẽ (kèm điều kiện toạ độ, xem “Lưu ý thao tác”), không đụng nội dung khác.

### Quy tắc vẽ tường, cửa sổ, cửa đi bổ sung (2026-11-11)
- **Tường:** tim tường ngoài cách mép ngoài 110 (tường 220), vách ngăn 110 theo tim; trục định vị lấy theo tim. Vẽ cả hệ bằng một lần `kt:walls` (cols = nil). **Ô cửa là khoảng hở giữa các đoạn tường** trong danh sách `ws`: tách đoạn tường tại mép ô cửa, không vẽ tường rồi cắt. Cột 220×220 (`kt:col`) đặt ở giao trục với tường ngoài.
- **Dạ cửa:** tại **mọi ô cửa sổ** vẽ thêm **hai nét mảnh (`G-Manh`) nối hai đầu tường** qua ô cửa, một nét theo mặt trong và một nét theo mặt ngoài tường, để thể hiện dạ cửa. Cửa đi không vẽ dạ.
- **Cửa sổ `cs2`/`cs4`:** đặt `Distance1` = bề rộng ô cửa, **`Distance` luôn = 140** (đặt theo bề dày tường 220 thì bbox lệch và cửa nhô khỏi tường). Điểm chèn = góc trái dưới ô cửa, cao độ y = mặt trong tường + (dày tường − 140)/2 để khung nằm giữa bề dày tường.
- **Cửa đi `cd1`/`cd2`:** điểm chèn = đầu khung (jamb) tại **mặt tường phía cánh mở**; `Distance1` = bề dày tường; chiều mở: rot 0 mở +y, 90 mở −x, 180 mở −y, 270 mở +x (khi rot 90/270 điểm chèn là đầu mút tương ứng của ô cửa: rot 90 lấy mép dưới ô cửa, rot 270 lấy mép trên). `cd1`: ô cửa rộng = `Distance` + 100; `cd2`: ô cửa rộng = `Distance`. Cửa chính mở ra ngoài; cửa phòng mở vào phòng, hoặc mở ra sảnh/hành lang nếu bên trong chật.
- Block động (cửa, cửa sổ) khi đổi tham số sẽ sinh block ẩn `*U…`: bình thường. Muốn chọn chúng bằng LISP thì lọc theo **layer** (`G-Cua`), không lọc theo tên block.
- **Thềm / ban công:** thềm vẽ `G-Thay`, ngoài mặt tiền, mỗi bậc ≥ 700 để ghi cao độ; ban công đua vẽ `G-Thay` + nét lan can `G-Manh` thụt vào 100; trên mặt bằng mái thể hiện ban công bằng nét `G-Khuat`.

### Lưu ý thao tác (rút ra khi làm)
- Trong `TEXT` tạo bằng LISP, ký tự `%` phải viết `%%%` mới hiện (`"10%%%"` → `10%`); `%%C` → Ø.
- `ssget "C"/"W"` chỉ chọn được vật thể **đang hiện trong khung nhìn** → `zoom_window` đủ lớn trước khi chọn.
- `ssget "X"` quét **cả bản vẽ** (có thể có nội dung khác như bản vẽ thử, block trùng tên ở xa): luôn kèm điều kiện toạ độ, hoặc kiểm tra điểm chèn nằm trong vùng đang làm trước khi mirror/xoá. Từng lật nhầm một block `cd4` ở ngoài vùng vẽ; đã lật lại.
- Văn bản Unicode trong chuỗi LISP gửi qua MCP: dùng `\U+xxxx`.

### Mặt bằng kết cấu / bố trí thép sàn
- Đường bao sàn, lỗ mở: G-Bo1. Dầm thấy: G-Bo2; dầm khuất (dưới sàn): G-Khuat dam. Cột cắt: G-Betong + SOLID.
- Thép chủ G-Steel1, thép đai/cấu tạo G-Steel2, ghi chú thép 125·k `Thang - Ghi chu`.
- Thép sàn: block động `Bo tri thep san` (attr `KHT` = số hiệu, `DKT` = "%%C10a200"; tham số L1, L3, D1, D2, L4, L5, `Chieu cao chu`) — mẫu chèn scale 100.

### Mặt bằng móng băng và mặt cắt móng băng (theo bản mẫu người dùng đưa, 2026-11-11)
Bản vẽ gồm: **mặt bằng kết cấu móng** (tỷ lệ như mặt bằng, dim `A3-N`), các **mặt cắt móng băng MB1, MB2**, **thép chờ cột** và **MC 1-1 (chờ cột)** vẽ tỷ lệ lớn trong cùng file, đặt cách xa nhau. Tỷ lệ chi tiết (1:20, 1:25…) và layer cụ thể của từng nét **hỏi người dùng khi vẽ**; chỉ dùng layer có sẵn (nét vàng mẫu = `G-Bo2`, thép chủ = `G-Steel1`, thép đai = `G-Steel2`, chữ xanh lá = `G-Text`, hatch = `G-Hatch`).

**A. Mặt bằng móng**
1. **Lưới trục + bóng trục cả 4 phía** (A, B, C theo cạnh dọc; 1, 2, 3 theo cạnh ngang), bóng trục hai bên trái/ phải đối xứng. Đường tim trục `G-Tim` kéo xuyên qua mặt bằng.
2. **Dim 2 lớp mỗi phía:** lớp trong = 110 – các nhịp trục – 110; lớp ngoài = tổng (vd 7600 × 7970). Phía trái/ phải làm đối xứng.
3. **Cột:** ô 220×220 tại **mọi giao trục** nằm trên đường bao móng, hatch BTCT, đặt đúng tim trục.
4. **Dải móng băng chạy dọc các trục có tường/ cột.** Đường bao ngoài của dải (hình chữ nhật nối các cột) và **bản móng ở các ô giữa**: mỗi ô là một hình chữ nhật đáy móng, bên trong thụt vào một hình chữ nhật nhỏ là **mép bản móng/ chân vát**; **bốn đường chéo ở góc** nối góc ngoài với góc trong thể hiện mặt vát của bản móng (cánh móng dốc).
5. **Móng ở biên (MB1) lệch tim, móng ở trục giữa (MB2) đối xứng qua tim.** Dim bề rộng móng ngay trên mặt bằng: tổng 1200; phần nhô mỗi phía (vd 1090 = 1200 − 110; 560/ 640 hai bên trục giữa; 600 + 600 cho móng đối xứng).
6. **Ghi tên móng** `MÓNG BĂNG MB1`, `MB2`... bằng chữ xanh lá in đậm (`G-Text`), **xoay theo hướng dải móng**, đặt trong ô, không đè nét. Tiêu đề bản vẽ `MẶT BẰNG KẾT CẤU MÓNG` h200 căn giữa dưới bóng trục.

**B. Mặt cắt móng băng (MB1: móng biên lệch tâm; MB2: móng giữa đối xứng)**
1. **Cao độ ghi bên trái bằng `Coskhac`:** `+0.000` (COS NỀN NHÀ), `-0.450` (COS SÂN), `-1.450` (đáy móng). Đường mức nét chấm gạch kéo ngang qua mặt cắt, kèm chữ `COS NỀN NHÀ`, `COS SÂN` (chữ nhỏ `Thang - Ghi chu`).
2. **Dim đứng 2 lớp bên trái:** lớp trong = từng đoạn (350 + 100 = 450 trên sân; 400 + 200 + 200 + 200 + 100 = 1100 từ −0.450 xuống lớp bê tông lót, trong đó 1000 là chiều sâu móng từ −0.450 đến −1.450); lớp ngoài = các tổng 450 và 1000.
3. **Kết cấu từ trên xuống:** giằng tường (BTCT, hatch BTCT, cao 100, cạnh cos nền nhà) → **tường móng xây gạch đặc dày 220** (hatch tường, cao 350 phía trên cos sân đến mặt móng, tính theo bản mẫu) → **móng BTCT** gồm cổ móng thẳng, vai rộng 50 mỗi bên, **mặt vát nghiêng** xuống cánh móng, đáy phẳng → **bê tông lót M100#, đá 4×6, dày 100, hatch chấm**, rộng hơn móng mỗi bên 100.
4. **MB1 (biên):** tim tường lệch về một phía; cánh móng một bên dài (900), bên kia chỉ 190 + 110 (tim tới mép ngoài) và chân thẳng. **MB2 (giữa):** đối xứng, mỗi bên cánh 450, hai bên vai 150 + 150 qua tim.
5. **Thép:** thép chủ giằng/ móng thể hiện bằng **chấm tròn đỏ (`G-Steel1`)**; thép đai và thép phân bố là nét xanh (`G-Steel2`) ôm trong mặt cắt; thép bản móng nằm sát đáy. Ghi chú thép có **số trong vòng tròn** (1, 2) + leader: `6/φ20` (thép giằng), `φ8a150`, `THÉP BẢN MÓNG /φ12a150` (nội dung ví dụ — lấy theo tính toán/ người dùng, không tự bịa).
6. **Dim ngang dưới chân:** lớp trong chia từng đoạn (100 – 110 – 190 – 900 – 100 cho MB1; 100 – 450 – 150 – 150 – 450 – 100 cho MB2), lớp ngoài = tổng 1200; **tim móng nối xuống bóng trục có dấu `*`** (trục móng).
7. **Ghi chú có leader mũi tên:** `GIẰNG TƯỜNG`, `TƯỜNG MÓNG XÂY GẠCH ĐẶC`, `BÊ TÔNG LÓT M100#, ĐÁ 4×6`, `THÉP BẢN MÓNG`. Tiêu đề dưới chi tiết (`MÓNG BĂNG MB1`) chữ xanh lá in đậm có gạch chân.
8. **Thép chờ cột (mặt cắt đứng):** thép chờ nhô **600** trên cos nền nhà, đai `φ6a150` trong cổ móng, chân thép bẻ L đặt sát đáy; ghi `THÉP CHỜ` (1), `φ6a150` (đ). **MC 1-1 (chờ cột):** ô 220×220, **lớp bảo vệ 25** mỗi phía, 4 thanh góc (chấm đỏ) `4/φ18`, đai `φ6a150`; tiêu đề `MC 1-1 (CHỜ CỘT)`.
9. Kiểm tra: bê tông lót nằm đúng dưới đáy móng, các cos khớp nhau giữa MB1, MB2 và thép chờ cột; số bậc dim cộng bằng tổng; mọi vòng tròn số thép có chú thích tương ứng.

### Mặt cắt
- **Ký hiệu cắt `KHcat2` trên mặt bằng**: đặt **ngoài vùng dim và bóng trục**, cách tường, dim, bóng trục, tiêu đề **≥ 300**. **Scale 0.5, bằng ký hiệu trục** (người dùng chốt 2026-11-11; scale 1 là quá to). Block nằm **dọc theo đường cắt** (tam giác nằm trên đường, bbox rộng 1331·scale dọc đường cắt, tức 665 ở scale 0.5; rot 0 mũi tên chỉ trái, rot 270 mũi tên chỉ lên, rot 90 chỉ xuống, rot 180 chỉ phải). Điểm chèn nằm ở **một đầu đáy tam giác**, nên tính vị trí theo mép trong của ký hiệu (mép gần mặt bằng) nằm đúng đầu đường cắt. Chèn rồi phải đặt lại chữ: số ở trên, `KT-xx` ở dưới tâm vòng tròn, rotation 0. Đường cắt (G-Manh) chạy từ mép trong ký hiệu này đến mép trong ký hiệu kia; không đặt ký hiệu đè lên tường, thềm, tường rào.
- Phần bị cắt (sàn, dầm, tường): G-Cat / G-Betong 0.40 + hatch; phần nhìn thấy phía sau: G-Thay; khuất: G-Khuat.
- Cao độ: `kt:cos` (block `Coskhac`, attr `+24.000`, ví dụ "+0.000", "+3.600"). **Cốt nền nhà luôn ghi `+0.000` (dấu cộng), không dùng `±0.000` và không gõ `%%P`** (người dùng chốt 2026-11-11); cốt dương luôn có dấu `+`, âm có dấu `-`. Mặt cắt nội thất dùng block `mc-*`, mặt đứng dùng `md-*`.

#### Chuẩn thể hiện mặt cắt đứng và mặt đứng (theo bản mẫu người dùng đưa, chốt 2026-11-11)
Áp dụng cho mặt cắt dọc/ ngang (trục 1-4, trục A-B) và mặt đứng. Dim style **`A3-100`** (tỷ lệ 1:100), đặt tường minh vì `kt:dim` dùng DIMSTYLE hiện hành.
1. **Cao độ và đường mức, cả hai bên.** Mỗi mức sàn (−0.450, +0.000, +3.900, +7.500, +11.100, +11.900…) kẻ **một đường mức nét chấm gạch xuyên suốt mặt cắt** (G-Manh), kéo ra **cả bên trái lẫn bên phải** tới ký hiệu `Coskhac`, ký hiệu ở ngoài cùng, **hai bên giống nhau**. Giá trị cao độ phải điền đủ.
2. **Dim đứng 2 lớp, cả hai bên, đối xứng.** Lớp trong: chuỗi chiều cao từng tầng (vd 450, 3900, 3600, 3600, 800); lớp ngoài: tổng cao (vd 12350). Chân dim cắt đúng đường mức (`kt:cutdim`).
3. **Dim ngang dưới chân.** Lớp trong: 110 (tường) – các nhịp trục – 110; lớp ngoài: tổng. Dưới cùng: bóng trục rồi tiêu đề `MẶT CẮT x-x` (`Thang - Tieu De`).
4. **Phần bị cắt:**
   - Tường: nét bao `G-Cat` (0.40) + hatch tường `G-Hatch` kín từ nền đến sàn trên.
   - **Sàn, dầm, lanh tô, cột bị cắt: `G-Betong` (0.40) + hatch.** Sàn mỗi tầng thể hiện chiều dày thật (≈ 120–150); dầm dưới sàn là phần nhô xuống ở vị trí trục có dầm.
   - **Sàn phải kéo hết bề rộng tường** (kể cả tường tum, tường biên): không được để đoạn tường nằm ngoài mép sàn; sàn mái kéo dài tới mép ngoài tường tum.
   - Móng/ nền: dưới +0.000 đến −0.450 thể hiện nền đất/ bê tông bằng hatch đậm; chân tường rộng hơn thân tường.
5. **Phần thấy phía sau (nét mảnh):**
   - **Cột trong nhà** (cột không bị cắt) vẽ bằng **hai nét đứng mảnh** `G-Manh` đúng bề rộng cột, theo từng tầng giữa hai sàn (không xuyên qua sàn).
   - **Tường trên trục không bị cắt** (vd tường trục 4 có ô cửa/ cửa sổ): vẽ nét mảnh `G-Manh` nối các đoạn tường qua ô trống, để thấy tường liên tục.
   - Cửa, cửa sổ, tủ, thiết bị thấy được: `G-Cua`, `G-Noithat` (dùng block `mc-*`/ khối chữ nhật mỏng), không hatch.
   - Lan can, bậc thềm thấy: `G-Thay`.
6. **Cầu thang:** vế cắt là bản thang có chiều dày, **hatch + viền `G-Betong`**; bậc nhìn thấy `G-Thay`/ `G-Manh`; chiếu nghỉ, chiếu tới là sàn cắt có hatch; tay vịn `G-Manh`. Số bậc, cao bậc khớp mặt bằng (quy tắc A3 của skill soát).
7. **Phần đua ra (ban công, lô gia):** sàn đua vẽ liền sàn, lan can phía ngoài. **Có dim khoảng đua** (vd 1200) nằm bên dưới sàn đua, mỗi tầng một dim, dùng `A3-100`. Tầng 1 không có ban công thì **không vẽ** lan can, ron, ô nét mảnh thừa.
8. **Tum / mái:** tường tum/ parapet thể hiện cao 800 trên sàn mái; sàn mái và **tum không đua ra ngoài ranh giới nhà** (mép ngoài tum không vượt mép tường bao, trừ khi có ban công đua đã dim).
9. **Mặt đứng riêng:** cùng quy tắc 1–3 (cao độ, dim đứng 2 lớp hai bên, dim ngang tổng); bên mặt tiền không có chi tiết thừa ở tầng không có (vd tầng 1 không ban công).
10. **Kiểm tra sau khi vẽ:** zoom từng tầng; kiểm tra (a) không còn tường ngoài sàn, (b) cột thấy đủ ở các trục, (c) dim hai bên đối xứng và cùng style `A3-100`, (d) mọi đường mức có ký hiệu cao độ cả hai bên.

## 6. Kiểm tra trước khi giao
- Không có đối tượng trên layer `0` (trừ trong block) — đếm bằng `entity count layer=0`.
- Màu/linetype/lineweight của entity = ByLayer.
- Cỡ chữ và dim style khớp tỷ lệ N đã chốt.
- Nét bao tường nằm trên **G-Cat**, là polyline kín; đọc đỉnh các khối tường: không còn cạnh dài ½ bề dày tường ở góc (dấu hiệu khuyết góc L).
- Mọi LINE G-Tim có linetype scale 0.5.
- Mọi `Coskhac` đã có giá trị thuộc tính `+24.000` (không trống).
- Chân dim đã cắt bằng `kt:cutdim` ở cả 4 phía, cho **mọi lớp dim** (kể cả dim đoạn tường và dim thêm sau này).
- Khoảng cách giữa các lớp dim đều nhau ở mọi phía.
- Screenshot sau `zoom_extents`; báo lại cho người dùng đã vẽ gì, ở tọa độ nào, tỷ lệ nào.

## 7. Sự cố kết nối autocad-mcp
- `no AutoCAD window found`: MCP chỉ nhận cửa sổ có `.dwg` hoặc `Drawing` trong tiêu đề → bản vẽ đang mở là `.dwt`. Nhờ người dùng **Save As .dwg** (cũng tránh ghi đè template).
- `mcp_dispatch.lsp not loaded` / mọi lệnh timeout: MCP gõ `(c:mcp-dispatch)` vào dòng lệnh → nếu Command Line bị ẩn thì không chạy. Nhờ người dùng bấm **Ctrl+9** để hiện dòng lệnh, Esc vài lần, rồi
  `(load "C:/Autodesk/MCP/autocad-mcp/lisp-code/mcp_dispatch.lsp")`, sau đó `system init` và nạp lại helpers.lsp.
- Tránh lệnh `command` tương tác dài (PEDIT, HATCH…) trong execute_lisp; dùng hàm VLA/entmake trong helpers.

## 8. Bài học khi vẽ công trình lớn (ví dụ nhà văn hóa 17.6×19.7)
- `execute_lisp` timeout 10 s → chia việc thành nhiều hàm `vh:*` nhỏ (mỗi lệnh < 1 s), nạp bằng `(load "C:/temp/xxx.lsp")`; `data` của `execute_lisp` là JSON `{"code": "..."}`.
- Không đặt tên tham số LISP là `t` (ký hiệu hằng) → lỗi "incorrect object to bind: T"; dùng `th`.
- Chuỗi tiếng Việt trong file .lsp: viết `\U+1EACU` (hai dấu `\`) để AutoCAD ra đúng ký tự.
- Quy ước chèn cửa: chèn ở mặt tường phía cánh mở, khung kéo về −y cục bộ; rot 0 mở +y, 180 mở −y, 270 mở +x, 90 mở −x; sau đó dịch bbox cho tâm = vị trí cửa (`vh:doorH/doorV`). cd1 bbox rộng = Distance+100, cd2/cd4 = Distance+135 (lệch −45).
- Ghế `Ghe 1` (610×546) scale 0.79, rot 270 quay về phía −x (sân khấu bên trái); `mb-xibet2` rot 0 = két nước ở +y.
- `get_screenshot` đôi khi trả ảnh cũ/cắt → xuất `(command "_.PNGOUT" "C:/temp/x.png" "")` rồi Read file PNG để kiểm tra toàn cảnh.
