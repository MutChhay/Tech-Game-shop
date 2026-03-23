<script setup>
import { ref } from 'vue'
import Login from '../components/views/login.vue'
import Register from '../components/views/register.vue'

defineProps(['isOpen'])
const emit = defineEmits(['close'])

const showLogin = ref(true)
</script>

<template>
  <Transition name="modal-fade">
    <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 overflow-hidden">
      
      <div 
        class="absolute inset-0 bg-neutral-950/80 backdrop-blur-sm transition-opacity" 
        @click="emit('close')"
      ></div>
      
      <div class="relative z-10 w-full max-w-md bg-white border border-white/10 rounded-2xl shadow-2xl p-6 md:p-8">

        <button 
          @click="emit('close')" 
          class="absolute top-4 right-4 text-zinc-500 hover:text-primary transition-colors p-2"
          aria-label="Close"
        >
          <span class="icon-[tabler--x] size-6"></span>
        </button>

        <Transition name="form-fade" mode="out-in">
          <div :key="showLogin">
            <Login 
              v-if="showLogin" 
              @open-register="showLogin = false"
            />

            <Register 
              v-else 
              @open-login="showLogin = true"
            />
          </div>
        </Transition>

      </div>
    </div>
  </Transition>
</template>

<style scoped>
/* --- Modal Entry/Exit Animation --- */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

/* Initial state for Modal (Invisible and shifted down) */
.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

/* The actual "Pop" effect for the box */
.modal-fade-enter-from .relative,
.modal-fade-leave-to .relative {
  transform: scale(0.9) translateY(30px);
}

/* --- Form Switch Animation (Login <-> Register) --- */
.form-fade-enter-active,
.form-fade-leave-active {
  transition: all 0.25s ease;
}

.form-fade-enter-from {
  opacity: 0;
  transform: translateX(10px);
}

.form-fade-leave-to {
  opacity: 0;
  transform: translateX(-10px);
}
</style>