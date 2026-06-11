# LogiSight - MVP Kapsam Planı 🚀

## 1. Problemin Tanımı
Lojistik ve taşımacılık sektöründe, sürücü davranışlarının (ani fren, sert ivmelenme, tehlikeli viraj alma) anlık olarak takip edilememesi güvenlik riskleri ve operasyonel verimsizlik yaratmaktadır. 

## 2. Çözüm Önerisi (LogiSight)
Sürücülerin mobil cihazlarından veya araç içi sistemlerinden alınan sensör (İvmeölçer ve Jiroskop) verilerini analiz ederek, yapay zeka destekli bir değerlendirme sunan tam yığın (full-stack) bir web platformu.

## 3. MVP Kapsamına Dahil Olanlar (In-Scope)
* **Veri Toplama:** 6 eksenli sensör verilerinin (GyroX, GyroY, GyroZ, AccX, AccY, AccZ) simüle edilerek veya cihazdan alınarak sisteme iletilmesi.
* **Yapay Zeka Destekli Analiz:** Gelen sensör verilerinin Python (FastAPI) tabanlı backend üzerinde makine öğrenmesi modelleri ve LLM (Gemini) entegrasyonu ile sınıflandırılması.
* **Kullanıcı Arayüzü (Dashboard):** Yöneticilerin sürücü durumlarını ve sefer analizlerini görebileceği temiz, modern bir Flutter Web arayüzü.

## 4. MVP Kapsamı Dışında Kalanlar (Out-of-Scope)
* Gerçek zamanlı GPS harita takibi (İleriki fazlarda eklenecek).
* Gelişmiş rol ve yetkilendirme yönetimi (Role-based Access Control).