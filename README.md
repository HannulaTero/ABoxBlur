# ABoxBlur
### [GameMaker] Arbitrarily sized box-blur for any pixel.

Use with ABoxBlur(_dst, _src, _blur, _strength, _fallback) 
- dst is destination surface
- src is source surface
- blur-mask is surface, which tells how strongly blur should be applied.
- strength is multiplier how strongly blur-mask is applied.
- fallback is whether use compatibility rgba8unorm-version (no float-textures). Default is false.


This asset works by applying parallel prefix sum in two axis to generate summed-area table. This table is sampled at the corners of desired box-blur area to calculate the sum of the area. As area is known, it can be use to divide the sum, calculating the average, which is the box-blur.

The parallel prefix scan is implemented in Hillis-Steele style, which is easy but work-inefficient approach. Blelloch would be better option, but it's harder to implement with fragment shaders _(but not impossible)_.

The examples currently always recreates the sum-table. This in some cases is not necessary _(source image doesn't change)_, and would be much more performant if it didn't do at those cases. The library will be changed to support getting the sum-table to apply it separately.


Itchio page: https://terohannula.itch.io/aboxblur
