<script setup>
import { ref } from 'vue';
import { ArrowRight, ShieldCheck } from 'lucide-vue-next';
import { RouterLink, useRouter } from 'vue-router';
import { useAuthStore } from '../../stores/auth';

const auth = useAuthStore();
const router = useRouter();
const form = ref({ email: '', password: '' });
const error = ref('');

async function submit() {
    error.value = '';
    try {
        await auth.login(form.value);
        await auth.hydrate();
        if (!auth.isAdmin) {
            auth.clear();
            error.value = 'This account does not have administrator access.';
            return;
        }
        router.push('/admin');
    } catch (requestError) {
        error.value = requestError.response?.data?.errors?.email?.[0]
            || requestError.response?.data?.message
            || 'The administrator credentials were not recognised.';
    }
}
</script>

<template>
    <section class="auth-page">
        <div class="auth-panel">
            <div class="auth-icon"><ShieldCheck :size="20" /></div>
            <p class="kicker">NEXUS OPERATIONS</p>
            <h1>Admin sign in.</h1>
            <p class="auth-intro">Only accounts with the administrator role can enter this dashboard.</p>
            <form @submit.prevent="submit">
                <label class="field-label">Email<input v-model="form.email" type="email" required autocomplete="username"></label>
                <label class="field-label">Password<input v-model="form.password" type="password" required autocomplete="current-password"></label>
                <p v-if="error" class="form-error">{{ error }}</p>
                <button class="button button-dark full-button" :disabled="auth.loading">{{ auth.loading ? 'Checking access...' : 'Enter dashboard' }} <ArrowRight :size="16" /></button>
            </form>
            <p class="auth-switch"><RouterLink to="/">Return to storefront</RouterLink></p>
        </div>
    </section>
</template>
