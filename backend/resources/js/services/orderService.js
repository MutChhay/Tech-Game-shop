import api from './api';

export const orderService = {
    create: () => api.post('/orders'),
    list: () => api.get('/orders'),
    get: (id) => api.get(`/orders/${id}`),
    cancel: (id) => api.post(`/orders/${id}/cancel`),
    adminList: () => api.get('/admin/orders'),
    updateStatus: (id, status) => api.patch(`/orders/${id}/status`, { status }),
};