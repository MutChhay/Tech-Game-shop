import { createRouter, createWebHistory } from "vue-router";
// CHANGE THIS:
import Home from "./Home.vue";
import NotFound from "./components/error/PageNotFound.vue";
import ProductList from "./components/views/ProductList.vue";
import ProductDetail from "./components/views/Projects/ProductDetail.vue";
import Carts from "./components/views/Projects/cart/Carts.vue";
import Checkout from "./components/views/Checkout.vue";
import MyOrders from "./components/orders/MyOrders.vue";
import OrderSuccess from "./components/orders/OrderSuccess.vue";
import OrderDetails from "./components/orders/OrderDetails.vue";
import About from "./components/AboutUS/About.vue";
import LoadingSpinner from "./loadingPages/loading.vue";
import Profile from "./components/Auth/views/Profile.vue";
const routes = [
    { path: "/", name: "Home", component: Home }, // Now it points to Home.vue
    { path: "/products/detail/:id", name: "ProductDetail", component: ProductDetail },
    { path: "/products/:category?", name: "Products", component: ProductList },
    { path: "/carts", name: "Carts", component: Carts },
    { path: "/checkout", name: "Checkout", component: Checkout },
    { path: "/orders", name: "Orders", component: MyOrders },
    { path: "/orders/:id/success", name: "OrderSuccess", component: OrderSuccess },
    { path: "/orders/:id", name: "OrderDetails", component: OrderDetails },
    { path: "/about", name: "About", component: About },
    { path: "/profile", name: "Profile", component: Profile },



    { path: '/:pathMatch(.*)*', name: 'NotFound', component: NotFound }
];

const router = createRouter({
    history: createWebHistory(),
    routes,

    scrollBehavior(to, from, savedPosition) {
        // When using browser back/forward
        if (savedPosition) {
            return savedPosition
        }

        // Always scroll to the top when changing pages
        return {
            top: 0,
            behavior: 'smooth',
        }
    },
})

export default router;