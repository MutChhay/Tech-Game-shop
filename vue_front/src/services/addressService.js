import api from './api'

export const addressService = {
    list: () => api.get('/addresses'),
    create: (payload) => api.post('/addresses', payload),
    update: (id, payload) => api.put(`/addresses/${id}`, payload),
    remove: (id) => api.delete(`/addresses/${id}`),
}