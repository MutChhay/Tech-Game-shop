import api from './api';

export const addressService = {
    list: () => api.get('/addresses'),
    create: (payload) => api.post('/addresses', payload),
};