;;; Helper cho skill autocad-kien-truc. Nap 1 lan / phien AutoCAD bang system execute_lisp.
;;; Tat ca ham tra ve ename (hoac T) de goi tiep.
(vl-load-com)
(setq *kt-doc* (vla-get-ActiveDocument (vlax-get-acad-object)))
(setq *kt-ms* (vla-get-ModelSpace *kt-doc*))
(if (not *kt-k*) (setq *kt-k* 1.0))   ; he so ty le k = N/100

;; Dat ty le ban ve 1:N -> k, dim style A3-N, LTSCALE in model
(defun kt:scale (n / ds)
  (setq *kt-k* (/ n 100.0))
  (setq ds (strcat "A3-" (itoa n)))
  (if (tblsearch "DIMSTYLE" ds) (command "_.-DIMSTYLE" "_R" ds))
  (setvar "LTSCALE" (* 10.0 n))
  (list n *kt-k* (getvar "DIMSTYLE")))

(defun kt:pt (x y) (vlax-3d-point (list (float x) (float y) 0.0)))

;; Line
(defun kt:line (x1 y1 x2 y2 lay)
  (entmakex (list '(0 . "LINE") (cons 8 lay)
                  (list 10 (float x1) (float y1) 0.0) (list 11 (float x2) (float y2) 0.0))))

;; LWPolyline: pts = '((x y) ...), closed = T/nil
(defun kt:pl (pts closed lay)
  (entmakex (append (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity") (cons 8 lay)
                          '(100 . "AcDbPolyline") (cons 90 (length pts)) (cons 70 (if closed 1 0)))
                    (mapcar '(lambda (p) (list 10 (float (car p)) (float (cadr p)))) pts))))

(defun kt:rect (x1 y1 x2 y2 lay)
  (kt:pl (list (list x1 y1) (list x2 y1) (list x2 y2) (list x1 y2)) T lay))

(defun kt:circle (cx cy r lay)
  (entmakex (list '(0 . "CIRCLE") (cons 8 lay) (list 10 (float cx) (float cy) 0.0) (cons 40 (float r)))))

;; Text: h = chieu cao THUC (da nhan k), just: 0 trai / 1 giua
(defun kt:text (x y s h sty lay / e)
  (setq e (vla-AddText *kt-ms* s (kt:pt x y) (float h)))
  (vla-put-StyleName e sty)
  (vla-put-Layer e lay)
  (vlax-vla-object->ename e))

;; Text canh giua tai (x,y), h tinh theo k: (kt:ctext x y "P.NGU" 220)
(defun kt:ctext (x y s hbase / e)
  (setq e (vla-AddText *kt-ms* s (kt:pt x y) (* hbase *kt-k*)))
  (vla-put-StyleName e "Thang - Tieu De")
  (vla-put-Layer e "G-Text")
  (vla-put-Alignment e acAlignmentMiddleCenter)
  (vla-put-TextAlignmentPoint e (kt:pt x y))
  (vlax-vla-object->ename e))

;; Chen block tren layer chi dinh. rot tinh bang DO.
(defun kt:ins (name x y sc rot lay / e)
  (setq e (vla-InsertBlock *kt-ms* (kt:pt x y) name (float sc) (float sc) (float sc) (* pi (/ rot 180.0))))
  (vla-put-Layer e lay)
  (vlax-vla-object->ename e))

;; Bounding box cua entity -> ((xmin ymin) (xmax ymax))
(defun kt:bbox (ent / mn mx)
  (vla-GetBoundingBox (vlax-ename->vla-object ent) 'mn 'mx)
  (setq mn (vlax-safearray->list mn) mx (vlax-safearray->list mx))
  (list (list (car mn) (cadr mn)) (list (car mx) (cadr mx))))

;; Chen block sao cho GOC DUOI-TRAI cua bbox nam tai (x,y) — dung cho noi that (diem chen block khong o goc)
(defun kt:insll (name x y sc rot lay / e b)
  (setq e (kt:ins name x y sc rot lay) b (car (kt:bbox e)))
  (vla-Move (vlax-ename->vla-object e) (kt:pt (car b) (cadr b)) (kt:pt x y))
  e)

;; Chen block sao cho TAM bbox nam tai (x,y)
(defun kt:insc (name x y sc rot lay / e b)
  (setq e (kt:ins name x y sc rot lay) b (kt:bbox e))
  (vla-Move (vlax-ename->vla-object e)
            (kt:pt (/ (+ (caar b) (caadr b)) 2.0) (/ (+ (cadar b) (cadadr b)) 2.0)) (kt:pt x y))
  e)

;; Gan tham so block dong: (kt:dyn ent "Distance" 900.0)
(defun kt:dyn (ent prop val / o r)
  (setq o (vlax-ename->vla-object ent))
  (foreach d (vlax-invoke o 'GetDynamicBlockProperties)
    (if (= (strcase (vla-get-PropertyName d)) (strcase prop))
      (progn (vla-put-Value d (vlax-make-variant val)) (setq r T))))
  r)

;; Liet ke tham so dong cua 1 block
(defun kt:dynlist (ent)
  (mapcar '(lambda (d) (cons (vla-get-PropertyName d) (vlax-variant-value (vla-get-Value d))))
          (vlax-invoke (vlax-ename->vla-object ent) 'GetDynamicBlockProperties)))

;; Gan thuoc tinh: (kt:att ent "DIMENSION" "900x2200")
(defun kt:att (ent tag val / r)
  (foreach a (vlax-invoke (vlax-ename->vla-object ent) 'GetAttributes)
    (if (= (strcase (vla-get-TagString a)) (strcase tag)) (progn (vla-put-TextString a val) (setq r T))))
  r)

;; Hatch cho 1 bien kin (polyline dong). pat: "SOLID" "ANSI31" "AR-CONC" "EARTH"...
(defun kt:hatch (ent pat sc / h arr)
  (setq h (vla-AddHatch *kt-ms* acHatchPatternTypePreDefined pat :vlax-true))
  (setq arr (vlax-make-safearray vlax-vbObject '(0 . 0)))
  (vlax-safearray-put-element arr 0 (vlax-ename->vla-object ent))
  (vla-AppendOuterLoop h arr)
  (if (/= pat "SOLID") (vla-put-PatternScale h (float sc)))
  (vla-put-Layer h "G-Hatch")
  (vla-Evaluate h)
  (vlax-vla-object->ename h))

;; Tuong DON LE (khong giao tuong khac): hinh chu nhat dong kin, layer G-Cat, hatch ANSI31.
;; Neu tuong giao nhau -> KHONG dung ham nay (se khuyet goc L), dung kt:walls ben duoi.
(defun kt:wall (x1 y1 x2 y2 th hatch / a dx dy p)
  (setq a (atan (- y2 y1) (- x2 x1)) dx (* (/ th 2.0) (- (sin a))) dy (* (/ th 2.0) (cos a)))
  (setq p (kt:pl (list (list (+ x1 dx) (+ y1 dy)) (list (+ x2 dx) (+ y2 dy))
                       (list (- x2 dx) (- y2 dy)) (list (- x1 dx) (- y1 dy))) T "G-Cat"))
  (if hatch (kt:hatch p "ANSI31" (* 20.0 *kt-k*)))
  p)

;; ---------- HE TUONG (giao nhau sach, khong khuyet goc) ----------
;; Khoang cach tu diem p den doan ab
(defun kt:segdist (p a b / dx dy l2 u q)
  (setq dx (- (car b) (car a)) dy (- (cadr b) (cadr a)) l2 (+ (* dx dx) (* dy dy)))
  (setq u (if (> l2 0) (/ (+ (* (- (car p) (car a)) dx) (* (- (cadr p) (cadr a)) dy)) l2) 0.0))
  (setq u (max 0.0 (min 1.0 u)) q (list (+ (car a) (* u dx)) (+ (cadr a) (* u dy))))
  (distance (list (car p) (cadr p)) q))

;; Noi cac doan thang (list (p1 p2)) thanh cac vong kin -> list cac list diem
(defun kt:chain (segs / loops s pts st en f)
  (while segs
    (setq s (car segs) segs (cdr segs) st (car s) en (cadr s) pts (list st en))
    (while (and (not (equal en st 0.5))
                (setq f (vl-some '(lambda (g) (if (or (equal (car g) en 0.5) (equal (cadr g) en 0.5)) g)) segs)))
      (setq segs (vl-remove f segs)
            en (if (equal (car f) en 0.5) (cadr f) (car f))
            pts (append pts (list en))))
    (if (equal en st 0.5) (setq pts (reverse (cdr (reverse pts)))))
    (setq loops (cons pts loops)))
  loops)

;; Bo dinh thang hang trong vong kin
(defun kt:simplify (pts / n i p0 p1 p2 r)
  (setq n (length pts) i 0)
  (repeat n
    (setq p0 (nth (rem (+ i n -1) n) pts) p1 (nth i pts) p2 (nth (rem (1+ i) n) pts))
    (if (> (abs (- (* (- (car p1) (car p0)) (- (cadr p2) (cadr p1)))
                   (* (- (cadr p1) (cadr p0)) (- (car p2) (car p1))))) 1.0)
      (setq r (cons p1 r)))
    (setq i (1+ i)))
  (reverse r))

;; Hatch 1 vong ngoai + cac vong trong (lo)
(defun kt:hatch2 (outer inners pat sc / h)
  (setq h (vla-AddHatch *kt-ms* acHatchPatternTypePreDefined pat :vlax-true))
  (vlax-invoke h 'AppendOuterLoop (list (vlax-ename->vla-object outer)))
  (foreach i inners (vlax-invoke h 'AppendInnerLoop (list (vlax-ename->vla-object i))))
  (if (/= pat "SOLID") (vla-put-PatternScale h (float sc)))
  (vla-put-Layer h "G-Hatch")
  (vla-Evaluate h)
  (vlax-vla-object->ename h))

;; VE CA HE TUONG MOT LAN.
;;  ws   = list (x1 y1 x2 y2 th) theo TIM tuong; cho cua: tach thanh 2 doan (khong keo dai qua lo cua).
;;  cols = list ename duong bao cot (G-Betong) de tru ra khoi tuong, hoac nil.
;;  hatch = T -> hatch ANSI31 20k tren G-Hatch.
;; Dau tuong cham vao tuong khac (goc L, chu T) duoc keo dai them th_khac/2 -> giao vuong goc, khong khuyet goc.
;; Ket qua: polyline kin layer G-Cat (moi khoi tuong 1 vong), tra ve list ename.
(defun kt:walls (ws cols hatch / rs w a b u ea eb dx dy ang p tmp reg objs lines todo o segs loops pls info outs ins bb)
  (foreach w ws
    (setq a (list (float (nth 0 w)) (float (nth 1 w))) b (list (float (nth 2 w)) (float (nth 3 w)))
          ang (angle a b) ea 0.0 eb 0.0)
    (foreach v ws
      (if (not (eq v w))
        (progn
          (if (< (kt:segdist a (list (nth 0 v) (nth 1 v)) (list (nth 2 v) (nth 3 v))) 1.0) (setq ea (max ea (/ (nth 4 v) 2.0))))
          (if (< (kt:segdist b (list (nth 0 v) (nth 1 v)) (list (nth 2 v) (nth 3 v))) 1.0) (setq eb (max eb (/ (nth 4 v) 2.0)))))))
    (setq a (polar a (+ ang pi) ea) b (polar b ang eb)
          dx (* (/ (nth 4 w) 2.0) (- (sin ang))) dy (* (/ (nth 4 w) 2.0) (cos ang)))
    (setq tmp (kt:pl (list (list (+ (car a) dx) (+ (cadr a) dy)) (list (+ (car b) dx) (+ (cadr b) dy))
                           (list (- (car b) dx) (- (cadr b) dy)) (list (- (car a) dx) (- (cadr a) dy))) T "G-Cat"))
    (setq rs (append rs (vlax-invoke *kt-ms* 'AddRegion (list (vlax-ename->vla-object tmp)))))
    (entdel tmp))
  (setq reg (car rs))
  (foreach r (cdr rs) (vla-Boolean reg acUnion r))
  (foreach c cols
    (foreach cr (vlax-invoke *kt-ms* 'AddRegion (list (vlax-ename->vla-object c)))
      (vla-Boolean reg acSubtraction cr)))
  ;; explode den khi chi con LINE
  (setq todo (list reg))
  (while todo
    (setq o (car todo) todo (cdr todo) objs (vlax-invoke o 'Explode))
    (vla-Delete o)
    (foreach x objs
      (if (= (vla-get-ObjectName x) "AcDbRegion") (setq todo (cons x todo)) (setq lines (cons x lines)))))
  (foreach l lines
    (setq segs (cons (list (list (car (vlax-get l 'StartPoint)) (cadr (vlax-get l 'StartPoint)))
                           (list (car (vlax-get l 'EndPoint)) (cadr (vlax-get l 'EndPoint)))) segs))
    (vla-Delete l))
  (foreach lp (kt:chain segs)
    (setq pls (cons (kt:pl (kt:simplify lp) T "G-Cat") pls)))
  ;; hatch: vong nam BEN TRONG vong khac (diem-trong-da-giac) = lo
  (if hatch
    (progn
      (setq info (mapcar '(lambda (e) (cons e (kt:plpts e))) pls))
      (foreach i info
        (if (not (vl-some '(lambda (j) (and (not (eq (car i) (car j))) (kt:inpoly (cadr i) (cdr j)))) info))
          (progn
            (setq ins nil)
            (foreach j info
              (if (and (not (eq (car i) (car j))) (kt:inpoly (cadr j) (cdr i)))
                (setq ins (cons (car j) ins))))
            (kt:hatch2 (car i) ins "ANSI31" (* 20.0 *kt-k*)))))))
  pls)

;; Dinh cua LWPOLYLINE -> list (x y)
(defun kt:plpts (e)
  (mapcar '(lambda (x) (list (cadr x) (caddr x))) (vl-remove-if-not '(lambda (x) (= (car x) 10)) (entget e))))

;; Diem p nam trong da giac pts (ray casting)
(defun kt:inpoly (p pts / n i j a b in)
  (setq n (length pts) i 0 j (1- n) in nil)
  (while (< i n)
    (setq a (nth i pts) b (nth j pts))
    (if (and (/= (> (cadr a) (cadr p)) (> (cadr b) (cadr p)))
             (< (car p) (+ (car a) (/ (* (- (car b) (car a)) (- (cadr p) (cadr a))) (- (cadr b) (cadr a))))))
      (setq in (not in)))
    (setq j i i (1+ i)))
  in)

;; Cot chu nhat tam (cx,cy) b x h, G-Betong + SOLID
(defun kt:col (cx cy b h / p)
  (setq p (kt:rect (- cx (/ b 2.0)) (- cy (/ h 2.0)) (+ cx (/ b 2.0)) (+ cy (/ h 2.0)) "G-Betong"))
  (kt:hatch p "SOLID" 1.0)
  p)

;; Truc: duong G-Tim tu (x1,y1)->(x2,y2) + bubble 'ky hieu truc' o dau (x1,y1), lui ra ngoai 1 khoang theo huong truc
;; ---------- TRUC (theo ban mau cua nguoi dung) ----------
;; Duong tim G-Tim, linetype scale 0.5; bong "ky hieu truc" scale 0.5, layer G-Tim, o CA HAI DAU,
;; tam bong cach dau duong tim 172 (ra ngoai). Tra ve list (line bong1 bong2).
(setq *kt-tim-lts* 0.5 *kt-bub-sc* 0.5 *kt-bub-off* 172.0)
(defun kt:axis (x1 y1 x2 y2 label / a l d e1 e2)
  (setq l (kt:line x1 y1 x2 y2 "G-Tim") d (entget l))
  (entmod (append d (list (cons 48 *kt-tim-lts*))))
  (setq a (atan (- y1 y2) (- x1 x2)))
  (setq e1 (kt:ins "ky hieu truc" (+ x1 (* *kt-bub-off* (cos a))) (+ y1 (* *kt-bub-off* (sin a))) *kt-bub-sc* 0 "G-Tim"))
  (setq e2 (kt:ins "ky hieu truc" (- x2 (* *kt-bub-off* (cos a))) (- y2 (* *kt-bub-off* (sin a))) *kt-bub-sc* 0 "G-Tim"))
  (kt:att e1 "1" label) (kt:att e2 "1" label)
  (list l e1 e2))

;; ---------- TEN PHONG + DIEN TICH (theo ban mau) ----------
;; Ten phong h132, duoi la "DT xx.xM2" h100, can giua (Center), style "Thang - Tieu De", G-Text.
;; (x,y) = tam nhan; dt = dien tich m2 (so). Tinh dt theo kich thuoc THONG THUY (mep trong tuong).
(defun kt:tc (x y s h / o)
  (setq o (vla-AddText *kt-ms* s (kt:pt x y) (float h)))
  (vla-put-StyleName o "Thang - Tieu De") (vla-put-Layer o "G-Text")
  (vla-put-Alignment o acAlignmentCenter) (vla-put-TextAlignmentPoint o (kt:pt x y))
  (vlax-vla-object->ename o))
(defun kt:room (x y name dt)
  (list (kt:tc x (+ y 40) name 132)
        (kt:tc x (- y 141) (strcat "DT " (rtos dt 2 1) "M2") 100)))

;; ---------- SO BAC CAU THANG (theo ban mau) ----------
;; Ghi so thu tu tung bac, chu h100 can giua tai tam bac. x = truc ghi so (lech ~110 canh mui ten di len),
;; y0 = tam bac dau tien, step = +-be rong bac (250), n = so bac, start = so dau tien.
(defun kt:stairodd (x y0 step / k r)
  ;; so bac le 1,3,5,7,9 (ket thuc tai 9); step = khoang cach giua 2 so
  (setq k 0)
  (foreach n '(1 3 5 7 9) (setq r (cons (kt:tc x (- (+ y0 (* k step)) 50) (itoa n) 100) r) k (1+ k)))
  r)
;; So bac le 1,3,5,... den n bac (vd 21 bac -> 1..21). step = khoang cach giua 2 so (= 2 x be rong mat bac, co dau theo chieu di len)
(defun kt:stairodd2 (x y0 step n / k v r)
  (setq k 0 v 1)
  (while (<= v n)
    (setq r (cons (kt:tc x (- (+ y0 (* k step)) 50) (itoa v) 100) r) k (1+ k) v (+ v 2)))
  r)
(defun kt:stairnum (x y0 step n start / i r)
  (setq i 0)
  (repeat n (setq r (cons (kt:tc x (- (+ y0 (* i step)) 50) (itoa (+ start i)) 100) r) i (1+ i)))
  r)

;; Kich thuoc thang/ngang: dim tu p1->p2, duong dim di qua (dx,dy). horiz T = ngang, nil = doc, :aligned = theo canh
(defun kt:dim (x1 y1 x2 y2 dx dy mode / d)
  (setq d (if (= mode :aligned)
            (vla-AddDimAligned *kt-ms* (kt:pt x1 y1) (kt:pt x2 y2) (kt:pt dx dy))
            (vla-AddDimRotated *kt-ms* (kt:pt x1 y1) (kt:pt x2 y2) (kt:pt dx dy) (if mode 0.0 (/ pi 2.0)))))
  (vla-put-StyleName d (getvar "DIMSTYLE"))
  (vla-put-Layer d "G-Dim")
  ;; theo ban mau: chan dim co dinh (DIMFXLON=1, DIMFXL=500)
  (if *kt-dimfxl* (progn (vla-put-ExtLineFixedLenSuppress d :vlax-true) (vla-put-ExtLineFixedLen d *kt-dimfxl*)))
  (vlax-vla-object->ename d))
(setq *kt-dimfxl* 500.0)

;; Chuoi kich thuoc: xs = '(x0 x1 x2 ...) tren cung y, dim ngang tai yd
(defun kt:dimchainx (xs y yd / r)
  (while (cadr xs) (setq r (cons (kt:dim (car xs) y (cadr xs) y (car xs) yd T) r)) (setq xs (cdr xs))) r)
(defun kt:dimchainy (ys x xd / r)
  (while (cadr ys) (setq r (cons (kt:dim x (car ys) x (cadr ys) xd (car ys) nil) r)) (setq ys (cdr ys))) r)

;; ---------- CAT CHAN DIM (thuat toan lenh CD2 trong CUTDIM.lsp, khong tuong tac) ----------
;; ents = list ename DIMENSION (cung 1 phia), pt = (x y) 1 diem tren duong "cat": moi chan dim (dxf 13/14)
;; duoc doi ve giao diem cua duong qua pt song song duong dim. Quy uoc: pt cach duong dim TRONG CUNG 400*k ve phia vat the.
(defun kt:cutdim (ents pt / n ds p10 p13 p14 gy gx pti)
  (setq pt (list (float (car pt)) (float (cadr pt)) 0.0) n 0)
  (foreach e ents
    (setq ds (entget e))
    (if (and (= (cdr (assoc 0 ds)) "DIMENSION") (member (cdr (assoc 70 ds)) '(0 32 33 160 161)))
      (progn
        (setq p10 (cdr (assoc 10 ds)) p13 (cdr (assoc 13 ds)) p14 (cdr (assoc 14 ds))
              gy (angle p10 p14) gx (+ gy (/ pi 2)) pti (polar pt gx 2))
        (setq ds (subst (cons 13 (inters pt pti p13 (polar p13 gy 2) nil)) (assoc 13 ds) ds))
        (setq ds (subst (cons 14 (inters pt pti p14 (polar p14 gy 2) nil)) (assoc 14 ds) ds))
        (entmod ds) (setq n (1+ n)))))
  n)

;; ---------- CAO DO ----------
;; Block Coskhac, thuoc tinh that la "+24.000" (KHONG phai "+22.00"). val vd "-0.150" "+0.000" "+0.000"
(setq *kt-cos-sc* 0.55)   ; scale cao do theo ban mau
(defun kt:cos (x y val / e)
  (setq e (kt:ins "Coskhac" x y *kt-cos-sc* 0 "G-Text"))
  (if (not (kt:att e "+24.000" val))
    (foreach a (vlax-invoke (vlax-ename->vla-object e) 'GetAttributes) (vla-put-TextString a val)))
  e)

(princ "kt helpers loaded")
