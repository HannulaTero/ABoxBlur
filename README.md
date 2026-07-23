# ABoxBlur
### [GameMaker] Arbitrarily sized box-blur for any pixel.
<img width="128" height="128" align="right" alt="icon-ABoxBlur" src="https://github.com/user-attachments/assets/5a01e534-d401-4cf3-830b-33c822d7cc68" />

Use with `ABoxBlur(_dst, _src, _blur, _strength, _fallback)`
- dst is destination surface
- src is source surface
- blur-mask is surface, which tells how strongly blur should be applied.
- strength is multiplier how strongly blur-mask is applied.
- fallback is whether use compatibility rgba8unorm-version (no float-textures). Default is false.

---

[YouTube video](https://www.youtube.com/watch?v=JSGCtvAgfrY)

[Itchio page](https://terohannula.itch.io/aboxblur)

---

This asset works by applying parallel prefix sum in two axis to generate summed-area table. This table is sampled at the corners of desired box-blur area to calculate the sum of the area. As area is known, it can be use to divide the sum, calculating the average, which is the box-blur.

The parallel prefix scan is implemented in Hillis-Steele style, which is easy but work-inefficient approach. Blelloch would be better option, but it's harder to implement with fragment shaders _(but not impossible)_.

The examples currently always recreates the sum-table. This in some cases is not necessary _(source image doesn't change)_, and would be much more performant if it didn't do at those cases. The library will be changed to support getting the sum-table to apply it separately.

---

<img width="480" height="270" alt="image 00" src="https://github.com/user-attachments/assets/1bdd9591-1332-48dc-b3cb-03d5d5a53eeb" />
<img width="480" height="270" alt="image 02" src="https://github.com/user-attachments/assets/84d1ebbd-774a-46f8-89f0-08ff889cf5a1" />
<img width="480" height="270" alt="image 01" src="https://github.com/user-attachments/assets/9143d1ea-4329-412f-9a7a-c0db1430da0a" />
<img width="480" height="270" alt="image 03" src="https://github.com/user-attachments/assets/09336062-0f7e-4cea-9c68-34c51a688103" />
<img width="480" height="270" alt="image 04" src="https://github.com/user-attachments/assets/9460385d-24a1-400e-9547-3ba1ae8c4a67" />
<img width="480" height="270" alt="image 05" src="https://github.com/user-attachments/assets/f3dcfef9-1e7a-4f7c-912b-b327602e914d" />
