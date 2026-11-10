# Danh mục block có sẵn trong "Kien truc Arch.dwt"

Kích thước = bounding box thực đo ở scale 1 (mm). Tiền tố: `mb-` mặt bằng, `md-` mặt đứng, `mc-` mặt cắt.
Chèn: `(kt:ins "<tên>" x y scale rot_độ "<layer>")`. Điểm chèn của tất cả block = gốc (0,0) của block.
Nội thất luôn chèn **scale 1** (kích thước thật) — chỉ ký hiệu chú thích mới nhân k.

## Ký hiệu / chú thích (layer G-Text, scale = k = N/100)
| Block | Thuộc tính (tag=mẫu) | Ghi chú |
|---|---|---|
| `ky hieu truc` | `1` = "1" | Bóng trục, Ø≈688 |
| `cactd` | `1` | Ký hiệu trục dọc (số) có đuôi |
| `cactn` | `A` | Ký hiệu trục ngang (chữ) có đuôi |
| `KHcat2` | `A` = tên mặt cắt, `KT-00` = số bản vẽ | Ký hiệu mặt cắt, động: Flip state, Angle |
| `A$C402D573F` | `01` = số chi tiết, `KT-00` = số bản vẽ | Ký hiệu trích chi tiết |
| `doorname` | `D1`, `DIMENSION` = "2000x2000", `SILL` = "%%P0.000" | Tag cửa đi |
| `vlc` | `N1` = "S1" | Tag cửa sổ / vách |
| `Coskhac` | `+24.000` = giá trị cao độ (vd "+0.000", "-0.150") | Cao độ, Visibility "Mat bang". Dùng `kt:cos`, luôn điền giá trị |
| `Bo tri thep san` | `KHT`=8, `DKT`="%%C10a200" | Thép sàn (layer 0 trong mẫu, chèn scale 100); động L1, L3, L4, L5, D1, D2, Chieu cao chu |
| `_ArchTick`, `_Dot` | — | Mũi tên dim (hệ thống) |

## Cửa (layer G-Cua) — đa số là block động
| Block | Kích thước | Tham số động chính |
|---|---|---|
| `Door 1canh (plan)` | 1000×1000 | `Door side-7`=930 (cánh), `Distance`=70 (khung), Flip state, Flip state1, Visibility "open 30"… |
| `Door 1 leav` | 1100×1070 | `Door Distance`=1000, `Frame Distance`=70, Lookup "Door1100", Visibility "30" |
| `Door 2canh (plan)` | 1500×1092 | `Distance`=1430 (khẩu độ), `Distance1`=250, Visibility "2canh deu nhau" |
| `Door - Double wing` | 1100×757 | `Door Distance`=1000, `Frame Distance`=150, Visibility "Lop-sided" |
| `cd1` | 900×910 | Cửa đi 1 cánh: `Distance`=800 (cánh), `Distance1`=110 (dày tường/khung), Angle |
| `cd2` | 1600×897 | Cửa đi 2 cánh: `Distance`=1510, `Distance1`=140 |
| `cd4` | 2700×792 | Cửa đi 4 cánh: `Distance`=2610, `Distance1`=140 |
| `Cua doi` | 1415×907 | Cửa 2 cánh lệch |
| `Cua 4 canh` | 1910×728 | Cửa 4 cánh xếp |
| `Cua buc ban` | 1528×589 | Cửa bục bản |
| `Window 1-2canh (plan)` | 2500×1518 | Cửa sổ, Visibility "1canh"/…, `Distance4`=2500, `Distance5`=140 |
| `cs2` | 900/1200×140 | Cửa sổ 2 cánh mặt bằng: `Distance1`=rộng, `Distance`=140 dày |
| `cs2d` | 1500×140 | Cửa sổ 2 cánh (đứng): `Distance1`, `Distance` |
| `cs4` | 2500×140 | Cửa sổ 4 cánh: `Distance1`=rộng, `Distance`=140 |
| `MC cua so` | 140×1750 | Mặt cắt cửa sổ: `Distance`=1350 cao, `Distance1`=140, `Distance2`=400 ô thoáng |
| `Swing Door`, `Revolving Door`, `Cua Kinh`, `Vach Ngan` | — | Cửa lật, cửa xoay, cửa kính (`Distance`), vách ngăn (`Distance`=dài) — mẫu đặt ở G-Noithat |

## Phòng khách / ăn (G-Noithat)
| Block | Kích thước |
|---|---|
| `bo salon2` | 3147×2134 |
| `bo salon3` | 3355×2637 |
| `bo salon4` | 3318×3253 |
| `bo salon5` | 2974×2270 |
| `bo salon7` | 3375×2747 |
| `bo salon8` | 2816×3270 |
| `bo salon9` | 4657×2245 |
| `bo salon10` | 2444×1809 |
| `TIVI42` | 1000×150 |
| `ban tron 4c d1000` | Ø1590 (bàn tròn 4 ghế) |
| `ban vuong 4c 1000x1000loai2` | 1828×1828 |
| `ban1200x900loai1` | 1345×1200 |
| `ban6c D1200` | 2243×2335 |
| `ban6c 1100x2000` | 2135×1800 |
| `ban6c 1000x2100` | 2649×2290 |
| `ban12c el1200x3300` | 4214×2139 |
| `ban26c oval2400x6300` | 7921×3735 |
| `Ghe 1`, `Ghe 2`, `Ghe 4`, `Ghe 5`, `Ghe bar`, `GHE-DUA`, `Ghe doi` | 500–870 (ghế đôi 2467×779); động: Angle |

## Phòng ngủ
| Block | Kích thước |
|---|---|
| `g.doi1800x2200` | 2800×2100 (giường đôi + tab) |
| `g.don1100x2000` | 1618×2000 |
| `tu quanao 600x2300` | 2000×600 |
| `tu quanao 600x2500` | 2500×781 |

## Bếp
| Block | Kích thước |
|---|---|
| `mb-bep1050x600` | 1050×600 |
| `DOUBLE-SINK1000X600` | 1000×600 |
| `mb-tulanh700x735` | 737×720 |
| `MBMAYGIAT` | 726×700 |

## Vệ sinh
| Block | Kích thước | Ghi chú |
|---|---|---|
| `mb-xibet2` / `md-xibet2` / `mc-xibet2` | 462×738 / 410×749 / 692×744 | Xí bệt MB / MĐ / MC |
| `Xi bet 2` | 890×1495 | Động, Visibility "MB" |
| `WC-P05` | 1003×1543 | Động, Visibility "MB" |
| `mb-lavabo1` / `md-lavabo1` / `mc-lavabo1` | 542×443 / 600×1440 / 509×495 | |
| `md-lavabo3` / `mc-lavabo3` | 1000×1350 / 510×1552 | |
| `lavabo1` … `lavabo12` | 400–660 × 340–520 | Lavabo mặt bằng các kiểu |
| `mb-tieunam1` / `md-tieunam1` / `mc-tieunam1` | 380×395 / 339×669 / 310×669 | Tiểu nam |
| `Tieu nam`, `tieu nam 1`, `tieu nam 2` | — | Động: Visibility "MB" / "mat bang" / "mat dung" |
| `mb-bontam1400x1400` | 1400×1400 | Bồn tắm góc |
| `mb-bontam4-1600x800` | 1600×800 | Bồn tắm |
| `mb-tamdung2-900x900` | 900×900 | Khu tắm đứng |
| `mb-voitam1`, `mb-voitam2`, `mb-voitam6`, `md-voitam1`, `voi2` | 100–340 | Vòi |
| `Voi sen`, `Voi sen 2`, `huongthuy` | ~200 | Sen tắm (huongthuy mẫu scale 6) |
| `MB lo giay`, `MD lo giay`, `MB treo khan` | 120–630 | Phụ kiện |
| `Ga thu nuoc` | 103 | Ga thu sàn (mẫu scale 0.9) |
| `XA`, `XA 1`, `XA 2`, `XA 3` | 50–170 | Xả / phụ kiện |
| `Bon nuoc dung`, `Bon nuoc nam` | 865×1872, 1566×1817 | Bồn nước inox, Visibility "MB" |

## Xe cộ (G-Noithat)
`mb-xecon1` 4804×1620, `mb-xecon4` 4500×1899 (ô tô); `Xe may 1/2/3` (động Visibility "MB"), `MB xe may 4` 530×1500, `MB xe may 5` 767×1597.

## Mái ngói (G-Noithat trong mẫu)
`MB ngoi bo`, `MD ngoi bo`, `MD2 ngoi bo`, `MC ngoi bo`, `MC ngoi ta`, `MC ngoi 1`, `MC ngoi 2` — động `Distance` (dài), `Distance1`.

## Cây xanh (layer G-Cay)
`mb-cay1`, `mb-cay2`, `mb-cay3`, `mb-cay5`…`mb-cay10`, `mb-cay12`, `mb-cay31`…`mb-cay37` — tán Ø1000–1800 ở scale 1; scale tự do theo kích thước tán.

## Block khác / tên rác (tránh dùng trừ khi người dùng chỉ định)
`dfadffdasgf`, `8VINSUL`, `A$C4AE13D6C`, `A$C2B1C0AE9`, `A$C3B37476A`, `A$C09E4537F`, `Vach Ngan`, `MD lo giay`…
