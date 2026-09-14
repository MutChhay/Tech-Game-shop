import api from './api';

export const cartService = {
    list: () => api.get('/cart'),
    add: (product_id, quantity = 1) => api.post('/cart', { product_id, quantity }),
    update: (id, quantity) => api.put(`/cart/${id}`, { quantity }),
    remove: (id) => api.delete(`/cart/${id}`),
};