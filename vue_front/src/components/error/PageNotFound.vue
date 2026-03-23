<template>

    <div id="NotFound">
  <main class="relative min-h-screen w-full flex flex-col items-center justify-center overflow-hidden bg-zinc-950 px-6">
    
    <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 size-[500px] rounded-full bg-red-600/10 blur-[120px] pointer-events-none"></div>
    <div class="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/carbon-fibre.png')] opacity-10 pointer-events-none"></div>

    <div class="z-10 text-center space-y-6">
      
      <div class="relative inline-block">
        <h1 class="text-[12rem] md:text-[16rem] font-black leading-none tracking-tighter text-white/5 italic select-none">
          404
        </h1>
        <div class="absolute inset-0 flex items-center justify-center">
          <h2 class="text-6xl md:text-8xl font-black text-white uppercase italic animate-glitch">
            Lost in <br /> <span class="text-primary">Space</span>
          </h2>
        </div>
      </div>

      <div class="max-w-md mx-auto space-y-4">
        <p class="text-zinc-500 font-mono text-sm md:text-base leading-relaxed uppercase tracking-widest">
          [ Error_Code: 0x000404 ] <br />
          The component you are looking for has been decommissioned or moved to another sector.
        </p>
      </div>

      <div class="flex flex-col sm:flex-row items-center justify-center gap-4 pt-8">
        <router-link 
          to="/" 
          class="btn btn-primary btn-lg rounded-none skew-x-[-12deg] px-10 font-black italic shadow-lg shadow-primary/20"
        >
          <span class="skew-x-[12deg]">Return to Base</span>
        </router-link>
        
        <button 
          @click="$router.go(-1)" 
          class="text-zinc-500 hover:text-white transition-colors font-bold uppercase tracking-widest text-xs"
        >
          Go Back
        </button>
      </div>

    </div>

    <div class="absolute bottom-8 w-full px-10 flex justify-between items-center opacity-20 hidden md:flex">
      <div class="flex gap-4 items-center">
        <div class="h-1 w-20 bg-zinc-800 rounded-full"></div>
        <span class="text-[10px] text-zinc-500 font-mono uppercase tracking-widest">System Status: Critical</span>
      </div>
      <span class="text-[10px] text-zinc-500 font-mono uppercase tracking-widest italic">TechStoreGame_Terminal_v2.0</span>
    </div>
  </main>
  </div>
</template>

<style scoped>
/* Glitch Animation */
@keyframes glitch {
  0% { transform: translate(0); }
  20% { transform: translate(-2px, 2px); }
  40% { transform: translate(-2px, -2px); }
  60% { transform: translate(2px, 2px); }
  80% { transform: translate(2px, -2px); }
  100% { transform: translate(0); }
}

.animate-glitch {
  animation: glitch 1s linear infinite;
  text-shadow: 
    2px 0 #ff0000, 
    -2px 0 #00ffff;
}

/* Subtle scanline effect overlay */
main::after {
  content: " ";
  display: block;
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  right: 0;
  background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.25) 50%), linear-gradient(90deg, rgba(255, 0, 0, 0.06), rgba(0, 255, 0, 0.02), rgba(0, 0, 255, 0.06));
  z-index: 2;
  background-size: 100% 2px, 3px 100%;
  pointer-events: none;
}
</style>