<template>
  <section class="slider-main">
    <!-- Backgrounds -->
    <div id="backgrounds">
      <div
        v-for="(background, index) in backgrounds"
        :key="index"
        class="background"
        :style="{
          background: background,
          opacity: currentIndex === index ? 1 : 0
        }"
      ></div>
    </div>

    <!-- Left Content -->
    <div class="container">
      <div class="logo">
        <a href="#">
          <img
            src="https://www.yudiz.com/codepen/headphone-slider/logo.svg"
            alt="logo"
          />
        </a>
      </div>

      <div class="slider-content-wrap">
        <div class="slider-content">
          <h2 class="heading-style-2">
            {{ t('banner.title') }}
          </h2>

          <p>
             {{ t('banner.Ltitle') }}
          </p>

          <h3 class="heading-style-2">
            $779.99
          </h3>

          <div class="social-icons">
            <a href="#">
              <img
                src="https://www.yudiz.com/codepen/headphone-slider/instagram-icon.svg"
                alt="Instagram"
              />
            </a>

            <a href="#">
              <img
                src="https://www.yudiz.com/codepen/headphone-slider/facbook-icon.svg"
                alt="Facebook"
              />
            </a>

            <a href="#">
              <img
                src="https://www.yudiz.com/codepen/headphone-slider/twiter-icon.svg"
                alt="Twitter"
              />
            </a>
          </div>
        </div>
      </div>
    </div>

    <!-- Slider Images -->
    <div class="slider-images">
      <img
        v-for="(image, index) in images"
        :key="index"
        :src="image"
        alt="headphone image"
        class="slider-image"
        :class="getImageClass(index)"
      />
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
/*
|--------------------------------------------------------------------------
| Images
|--------------------------------------------------------------------------
*/

const images = [
  'https://www.yudiz.com/codepen/headphone-slider/green.png',
  'https://www.yudiz.com/codepen/headphone-slider/blue.png',
  'https://www.yudiz.com/codepen/headphone-slider/red.png',
  'https://www.yudiz.com/codepen/headphone-slider/white.png',
  'https://www.yudiz.com/codepen/headphone-slider/black.png'
]

/*
|--------------------------------------------------------------------------
| Background colors
|--------------------------------------------------------------------------
*/

const backgrounds = [
  'radial-gradient(50% 50% at 50% 50%, #C7F6D0 0%, #7CB686 92.19%)',

  'radial-gradient(50% 50% at 50% 50%, #D1E4F6 0%, #5F9CCF 100%)',

  'radial-gradient(50% 50% at 50% 50%, #FFB7B2 0%, #ED746E 100%)',

  'radial-gradient(50% 50% at 50% 50%, #D7D7D7 0%, #979797 100%)',

  'radial-gradient(50% 50% at 50% 50%, #6B6B6B 0%, #292929 100%)'
]

/*
|--------------------------------------------------------------------------
| Current slider
|--------------------------------------------------------------------------
*/

const currentIndex = ref(0)

let sliderInterval = null

/*
|--------------------------------------------------------------------------
| Get image class
|--------------------------------------------------------------------------
*/

const getImageClass = (index) => {
  const total = images.length

  const previousIndex =
    (currentIndex.value - 1 + total) % total

  const nextIndex =
    (currentIndex.value + 1) % total

  if (index === currentIndex.value) {
    return 'active'
  }

  if (index === previousIndex) {
    return 'previous'
  }

  if (index === nextIndex) {
    return 'next'
  }

  return 'inactive'
}

/*
|--------------------------------------------------------------------------
| Next slide
|--------------------------------------------------------------------------
*/

const nextSlide = () => {
  currentIndex.value =
    (currentIndex.value + 1) % images.length
}

/*
|--------------------------------------------------------------------------
| Start slider
|--------------------------------------------------------------------------
*/

onMounted(() => {
  sliderInterval = setInterval(() => {
    nextSlide()
  }, 3000)
})

/*
|--------------------------------------------------------------------------
| Stop slider when component is destroyed
|--------------------------------------------------------------------------
*/

onUnmounted(() => {
  clearInterval(sliderInterval)
})
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;900&display=swap');

/* =========================================================
   RESET
========================================================= */




img {
  user-select: none;
}

a {
  display: inline-block;
}

/* =========================================================
   TEXT
========================================================= */

.heading-style-2 {
  color: #fff;
  font-size: 50px;
  font-weight: 900;
  line-height: 50px;
  margin-bottom: 40px;
}

.p {
  color: #fff;
  font-family: 'Montserrat', sans-serif;
  font-size: 18px;
  font-style: normal;
  font-weight: 400;
  line-height: 35px;
  margin-bottom: 28px;
}

/* =========================================================
   MAIN SLIDER
========================================================= */

.slider-main {
  min-height: 600px;

  background:
    radial-gradient(
      50% 50% at 50% 50%,
      #c7f6d0 0%,
      #7cb686 92.19%
    );
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  overflow: hidden;
  position: relative;

  z-index: 1;
}

/* =========================================================
   BACKGROUNDS
========================================================= */

#backgrounds {
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;

  z-index: -1;
}

.background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  transition: opacity 2s ease-in-out;
}

/* =========================================================
   CONTAINER
========================================================= */

.container {
  position: relative;

  left: max(24px, calc(50% - (1140px / 2)));

  width: 50%;

  padding-block: 100px;

  max-width: 525px;

  height: 100%;
}

/* =========================================================
   LOGO
========================================================= */

.logo a {
  margin-bottom: 20px;
}

.logo a img {
  width: 271px;
  height: auto;
}

/* =========================================================
   CONTENT
========================================================= */

.slider-content-wrap {
  display: flex;

  flex-direction: column;

  justify-content: center;

  height: 100%;
}

/* =========================================================
   SOCIAL ICONS
========================================================= */

.social-icons {
  display: flex;

  align-items: center;

  gap: 16px;
}

.social-icons a {
  border: 2px solid #fff;

  border-radius: 50%;

  width: 45px;
  height: 45px;

  display: flex;

  justify-content: center;
  align-items: center;
}

.social-icons img {
  width: 22px;
  height: 22px;
}

/* =========================================================
   SLIDER IMAGES
========================================================= */

.slider-images {
  position: relative;

  width: 50%;

  height: 100%;

  top: 0;
}

.slider-images > img {
  position: absolute;

  top: 0%;
  left: 100%;

  filter: blur(25px);

  transform:
    translate(-50%, -50%)
    scale(0.3);

  transition:
    opacity 2s ease,
    transform 2s ease,
    filter 2s ease,
    left 2s ease,
    top 2s ease;

  object-fit: cover;

  max-width: 593px;
  max-height: 779px;

  height: 100%;

  min-height: 320px;
}

/* =========================================================
   ACTIVE IMAGE
========================================================= */

.slider-images > img.active {
  opacity: 1;

  filter: blur(0px);

  left: 0;

  top: 50%;

  transform: translateY(-50%);

  z-index: 1;
}

/* =========================================================
   NEXT IMAGE
========================================================= */

.slider-images > img.next {
  opacity: 1;

  filter: blur(35px);

  left: 100%;

  top: 10%;

  transform:
    translate(-50%, -50%)
    scale(0.3);
}

/* =========================================================
   PREVIOUS IMAGE
========================================================= */

.slider-images > img.previous {
  opacity: 1;

  filter: blur(25px);

  left: 95%;

  top: 90%;
}

/* =========================================================
   INACTIVE IMAGE
========================================================= */

.slider-images > img.inactive {
  opacity: 0;

  filter: blur(35px);

  left: 100%;

  top: 100%;

  transform:
    translate(10%, 10%)
    scale(0.3);
}

/* =========================================================
   1199px
========================================================= */

@media screen and (max-width: 1199px) {

  .logo a img {
    width: 230px;
  }

  .heading-style-2 {
    font-size: 40px;
    line-height: 45px;
    margin-bottom: 30px;
  }

  .p {
    font-size: 17px;
    line-height: 28px;
    margin-bottom: 22px;
  }

  .container {
    left: calc(50% - (920px / 2));

    padding-block: 80px;

    max-width: 475px;
  }

  .slider-images > img {
    width: 453px;

    height: auto;

    aspect-ratio: 1 / 1.3;
  }
}

/* =========================================================
   991px
========================================================= */

@media screen and (max-width: 991px) {

  .logo a img {
    width: 210px;
  }

  .heading-style-2 {
    font-size: 35px;
    line-height: 43px;
    margin-bottom: 22px;
  }

  .p {
    font-size: 16px;
    line-height: 26px;
    margin-bottom: 18px;
  }

  .container {
    left: calc(50% - (720px / 2));

    padding-block: 70px;

    max-width: 405px;
  }

  .slider-images {
    width: 45%;
  }

  .slider-images > img {
    width: 340px;

    aspect-ratio: 1 / 1.3;
  }
}

/* =========================================================
   767px
========================================================= */

@media screen and (max-width: 767px) {

  .logo a img {
    width: 200px;
  }

  .logo a {
    margin-bottom: 20px;
  }

  .slider-main {
    flex-direction: column;

    min-height: 0;
    padding-bottom: 32px;
  }

  .social-icons a {
    width: 35px;
    height: 35px;
  }

  .social-icons img {
    width: 16px;
    height: 16px;
  }

  .container {
    position: unset;

    padding: 56px 24px 0;

    max-width: 540px;

    width: 100%;
  }

  .slider-images {
    width: 100%;
    height: 360px;
    min-height: 0;
  }

  .slider-images > img {
    height: min(380px, 72vw);

    aspect-ratio: 1 / 1.3;

    width: auto;
  }

  .slider-images > img.active {
    top: 50%;
    left: 50%;
  }
}

/* =========================================================
   575px
========================================================= */

@media screen and (max-width: 575px) {

  .logo a img {
    width: 180px;
  }

  .logo a {
    margin-bottom: 18px;
  }

  .heading-style-2 {
    font-size: clamp(26px, 8vw, 30px);

    line-height: 40px;

    margin-bottom: 20px;
  }

  .p {
    font-size: 15px;

    line-height: 24px;

    margin-bottom: 16px;
  }

  .social-icons a {
    width: 32px;
    height: 32px;
  }

  .social-icons img {
    width: 15px;
    height: 15px;
  }

  .container {
    padding: 50px 20px;

    max-width: 100%;
  }

  .slider-images > img {
    height: min(300px, 72vw);
  }

  .slider-images > img.active {
    top: 50%;
    left: 50%;
  }

  .slider-images > img.previous {
    top: 100%;
  }
}
</style>