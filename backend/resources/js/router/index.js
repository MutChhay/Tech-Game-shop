import { createRouter, createWebHashHistory } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import HomeView from '../views/HomeView.vue';
import ProductsView from '../views/ProductsView.vue';
import ProductView from '../views/ProductView.vue';
import CartView from '../views/CartView.vue';
import CheckoutView from '../views/CheckoutView.vue';
import LoginView from '../views/auth/LoginView.vue';
import RegisterView from '../views/auth/RegisterView.vue';
import AdminLoginView from '../views/auth/AdminLoginView.vue';
import OrdersView from '../views/orders/OrdersView.vue';
import OrderView from '../views/orders/OrderView.vue';
import SuccessView from '../views/orders/SuccessView.vue';
import AdminView from '../views/admin/AdminView.vue';
import AdminProductsView from '../views/admin/AdminProductsView.vue';

const router = createRouter({
    history: createWebHashHistory(),
    routes: [
        { path: '/', component: HomeView },
        { path: '/products', component: ProductsView },
        { path: '/products/:id', component: ProductView },
        { path: '/cart', component: CartView, meta: { auth: true } },
        { path: '/checkout', component: CheckoutView, meta: { auth: true } },
        { path: '/login', component: LoginView, meta: { guest: true } },
        { path: '/register', component: RegisterView, meta: { guest: true } },
        { path: '/admin/login', component: AdminLoginView, meta: { adminLogin: true } },
        { path: '/orders', component: OrdersView, meta: { auth: true } },
        { path: '/orders/:id', component: OrderView, meta: { auth: true } },
        { path: '/order-success/:id', component: SuccessView, meta: { auth: true } },
        { path: '/admin', component: AdminView, meta: { auth: true, admin: true } },
        { path: '/admin/products', component: AdminProductsView, meta: { auth: true, admin: true } },
    ],
    scrollBehavior: () => ({ top: 0 }),
});

router.beforeEach(async(to) => {
    const auth = useAuthStore();
    if ((to.meta.admin || to.meta.adminLogin) && auth.token) await auth.hydrate();
    if (to.meta.admin && !auth.isAuthenticated) return { path: '/admin/login', query: { redirect: to.fullPath } };
    if (to.meta.admin && !auth.isAdmin) return { path: '/admin/login', query: { redirect: to.fullPath } };
    if (to.meta.adminLogin && auth.isAdmin) return '/admin';
    if (to.meta.auth && !auth.isAuthenticated) return { path: '/login', query: { redirect: to.fullPath } };
    if (to.meta.guest && auth.token) await auth.hydrate();
    if (to.meta.guest && auth.isAuthenticated) return '/';
    if (to.meta.admin && !auth.isAdmin) return '/';
});

export default router;