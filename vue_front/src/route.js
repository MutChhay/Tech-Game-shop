import { createRouter, createWebHistory } from "vue-router";
// CHANGE THIS:
import Home from "./Home.vue";
import NotFound from "./components/error/PageNotFound.vue";
import Test from "./test.vue";

const routes = [
    { path: "/", name: "Home", component: Home }, // Now it points to Home.vue
    { path: "/test", name: "Test", component: Test },
    {
        path: '/:pathMatch(.*)*',
        name: 'NotFound',
        component: NotFound,
    },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

export default router;