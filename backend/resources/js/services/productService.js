import api from './api';

export const productService = {
    list: () => api.get('/products'),
    get: (id) => api.get(`/products/${id}`),
    categories: () => api.get('/categories'),
    create: (payload) => api.post('/products', payload),
    update: (id, payload) => api.post(`/products/${id}`, payload),
    remove: (id) => api.delete(`/products/${id}`),
    createCategory: (payload) => api.post('/categories', payload),
    updateCategory: (id, payload) => api.put(`/categories/${id}`, payload),
    removeCategory: (id) => api.delete(`/categories/${id}`),
};