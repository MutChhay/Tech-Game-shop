<template>
  <section class="relative min-h-[90vh] w-full overflow-hidden bg-neutral-950 flex items-center pt-20 lg:pt-0">
    
    <div class="absolute top-1/4 -left-20 size-[300px] md:size-[500px] rounded-full bg-primary/20 blur-[100px] md:blur-[120px]"></div>
    <div class="absolute bottom-1/4 -right-20 size-[250px] md:size-[400px] rounded-full bg-secondary/10 blur-[80px] md:blur-[100px]"></div>
    <div class="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/carbon-fibre.png')] opacity-10 pointer-events-none"></div>

    <div class="container mx-auto px-6 lg:px-12 z-10">
      <div class="flex flex-col lg:flex-row items-center justify-between gap-12 lg:gap-8">
        
        <div class="flex-1 text-center lg:text-left space-y-6 md:space-y-8 order-2 lg:order-1">
          <div class="inline-flex items-center rounded-full border border-white/10 bg-white/5 px-4 py-1.5 text-[10px] md:text-xs font-bold tracking-widest text-primary backdrop-blur-md uppercase">
            <span class="mr-2 inline-block size-2 animate-pulse rounded-full bg-primary shadow-[0_0_8px_#641ae6]"></span>
            RTX 5090 SERIES NOW IN STOCK
          </div>

          <h1 class="text-4xl sm:text-5xl md:text-6xl lg:text-8xl font-black tracking-tighter text-white uppercase italic leading-[0.9]">
            Unleash <br />
            <span class="bg-gradient-to-r from-primary via-purple-500 to-secondary bg-clip-text text-transparent filter drop-shadow-sm">
              Ultimate Power
            </span>
          </h1>

          <p class="max-w-xl text-base md:text-lg text-white/50 leading-relaxed mx-auto lg:mx-0 font-medium">
            Build your dream setup with the world's most powerful hardware. 
            From custom water-cooled rigs to professional workstations.
          </p>

          <div class="flex flex-col sm:flex-row justify-center lg:justify-start gap-4 pt-4">
            <button class="btn btn-primary btn-lg rounded-xl px-10 font-black uppercase tracking-wider shadow-[0_10px_20px_-5px_rgba(100,26,230,0.4)] hover:scale-105 active:scale-95 transition-all duration-300">
              Shop Build Kits
            </button>
            <button class="btn btn-outline btn-lg rounded-xl px-10 text-white border-white/20 hover:bg-white/5 hover:border-white/40 transition-all">
              PC Builder
            </button>
          </div>

          <div class="flex justify-center lg:justify-start gap-10 pt-10 border-t border-white/10">
            <div class="group">
              <p class="text-3xl font-black text-white group-hover:text-primary transition-colors">2.5k+</p>
              <p class="text-[10px] uppercase tracking-[0.3em] text-white/30">PC Built</p>
            </div>
            <div class="h-12 w-px bg-gradient-to-b from-transparent via-white/20 to-transparent"></div>
            <div class="group">
              <p class="text-3xl font-black text-white group-hover:text-secondary transition-colors">24h</p>
              <p class="text-[10px] uppercase tracking-[0.3em] text-white/30">Support</p>
            </div>
          </div>
        </div>

        <div class="flex-1 relative group order-1 lg:order-2 w-full max-w-[500px] lg:max-w-none">
          <div class="absolute inset-0 bg-primary/20 blur-[60px] md:blur-[100px] rounded-full scale-90 group-hover:scale-110 transition-transform duration-1000"></div>
          
          <img 
            src="../../assets/images/image.png" 
            alt="Gaming PC Case" 
            class="relative z-10 w-full h-auto drop-shadow-[0_20px_50px_rgba(0,0,0,0.8)] animate-float drop-shadow-primary"
          />
        </div>

      </div>
    </div>

    <div class="absolute bottom-0 left-0 w-full h-32 bg-gradient-to-t from-neutral-950 to-transparent"></div>
  </section>
</template>

<style scoped>
@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-25px) rotate(1deg); }
}

.animate-float {
  animation: float 7s ease-in-out infinite;
}

/* Adds a subtle primary glow to the image itself */
.drop-shadow-primary {
  filter: drop-shadow(0 0 15px rgba(100, 26, 230, 0.2));
}

/* Custom font smoothing for dark backgrounds */
h1, p {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>