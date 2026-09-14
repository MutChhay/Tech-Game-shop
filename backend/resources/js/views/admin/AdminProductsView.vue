<script setup>
import { computed, onMounted, ref } from 'vue';
import { ArrowLeft, ImagePlus, Pencil, Plus, Save, Trash2, X } from 'lucide-vue-next';
import { RouterLink } from 'vue-router';
import { productService } from '../../services/productService';

const products = ref([]);
const categories = ref([]);
const loading = ref(true);
const saving = ref(false);
const error = ref('');
const notice = ref('');
const editing = ref(null);
const imageFiles = ref([]);
const imagePreviews = ref([]);
const imagePreview = computed(() => imagePreviews.value[0] || '');
const fileInput = ref(null);
const form = ref(blankForm());

function blankForm() {
    return { name: '', price: '', stock: '', description: '', category_id: '', cpu: '', ram: '', storage: '', gpu: '', display: '', battery: '', warranty: '' };
}
const needsSpecs = computed(() => ['1', '2', 1, 2].includes(form.value.category_id));
const categoryName = (id) => categories.value.find((category) => String(category.id) === String(id))?.name || 'Uncategorised';

function errorMessage(requestError, fallback) {
    return Object.values(requestError.response?.data?.errors || {}).flat()[0] || requestError.response?.data?.message || fallback;
}
async function load() {
    loading.value = true; error.value = '';
    try { const [productsResponse, categoriesResponse] = await Promise.all([productService.list(), productService.categories()]); products.value = productsResponse.data; categories.value = categoriesResponse.data; }
    catch (requestError) { error.value = errorMessage(requestError, 'Unable to load product management.'); }
    finally { loading.value = false; }
}
function openCreate() { editing.value = null; form.value = blankForm(); imageFiles.value = []; imagePreviews.value = []; error.value = ''; }
function editProduct(product) { editing.value = product; form.value = { name: product.name || '', price: Number(product.price || 0), stock: product.stock ?? '', description: product.description || '', category_id: product.category_id || '', cpu: product.cpu || '', ram: product.ram || '', storage: product.storage || '', gpu: product.gpu || '', display: product.display || '', battery: product.battery || '', warranty: product.warranty || '' }; imageFiles.value = []; imagePreviews.value = product.images || (product.image_url ? [product.image_url] : []); error.value = ''; }
function chooseImage(event) { const files = Array.from(event.target.files || []); if (!files.length) return; if (files.length > 7 || (!editing.value && imageFiles.value.length + files.length > 7)) { error.value = 'You can add a maximum of 7 images.'; return; } const invalid = files.find((file) => !['image/jpeg', 'image/png'].includes(file.type)); if (invalid) { error.value = 'Choose JPG or PNG images only.'; return; } const oversized = files.find((file) => file.size > 2 * 1024 * 1024); if (oversized) { error.value = 'Each image must be 2 MB or smaller.'; return; } imageFiles.value = editing.value ? files : [...imageFiles.value, ...files]; imagePreviews.value = editing.value ? files.map((file) => URL.createObjectURL(file)) : [...imagePreviews.value, ...files.map((file) => URL.createObjectURL(file))]; event.target.value = ''; }
function buildPayload() { const payload = new FormData(); Object.entries(form.value).forEach(([key, value]) => { if (value !== '' && value !== null && value !== undefined) payload.append(key, value); }); imageFiles.value.forEach((file) => payload.append('images[]', file)); if (editing.value) payload.append('_method', 'PUT'); return payload; }
async function save() { saving.value = true; error.value = ''; notice.value = ''; try { await (editing.value ? productService.update(editing.value.id, buildPayload()) : productService.create(buildPayload())); notice.value = editing.value ? 'Product updated successfully.' : 'Product published successfully.'; closeForm(); await load(); } catch (requestError) { error.value = errorMessage(requestError, 'Product could not be saved.'); } finally { saving.value = false; } }
async function remove(product) { if (!window.confirm(`Remove ${product.name}?`)) return; try { await productService.remove(product.id); notice.value = 'Product removed.'; await load(); } catch (requestError) { error.value = errorMessage(requestError, 'Product could not be removed.'); } }
function closeForm() { editing.value = null; form.value = blankForm(); imageFiles.value = []; imagePreviews.value = []; }
onMounted(async () => { await load(); fileInput.value?.setAttribute('multiple', 'multiple'); });
</script>

<template>
    <section class="container page-section admin-products-page">
        <div class="section-heading"><div><RouterLink class="back-link" to="/admin"><ArrowLeft :size="16" /> Back to dashboard</RouterLink><p class="kicker admin-kicker">CATALOG MANAGEMENT</p><h1>Products</h1><p class="muted">Publish polished product listings with the fields your store already supports.</p></div><button class="button button-accent" @click="openCreate"><Plus :size="17" /> Add product</button></div>
        <p v-if="notice" class="success-message">{{ notice }}</p><p v-if="error" class="form-error">{{ error }}</p>
        <div class="product-admin-layout">
            <div class="admin-product-list"><div class="admin-list-head"><span>{{ products.length }} products</span><span>Manage your customer catalog</span></div><div v-if="loading" class="state">Loading products...</div><div v-else-if="!products.length" class="state"><ImagePlus :size="30" /><h3>Your catalog is empty.</h3><p>Add your first product to make it visible to customers.</p></div><article v-for="product in products" v-else :key="product.id" class="admin-product-row"><div class="admin-product-image"><img v-if="product.image_url" :src="product.image_url" :alt="product.name"><span v-else>N</span></div><div class="admin-product-copy"><strong>{{ product.name }}</strong><span>{{ categoryName(product.category_id) }}</span><small>${{ Number(product.price).toLocaleString() }} · {{ product.stock }} in stock</small></div><button class="icon-action admin-edit" title="Edit product" @click="editProduct(product)"><Pencil :size="16" /></button><button class="icon-action admin-delete" title="Delete product" @click="remove(product)"><Trash2 :size="16" /></button></article></div>
            <form class="product-editor" @submit.prevent="save"><div class="editor-header"><div><p class="eyebrow">{{ editing ? 'EDIT LISTING' : 'NEW LISTING' }}</p><h2>{{ editing ? 'Refine product' : 'Add a product' }}</h2></div><button v-if="editing" type="button" class="icon-action" title="Close editor" @click="closeForm"><X :size="17" /></button></div><label class="field-label">Product name<input v-model="form.name" required maxlength="255" placeholder="e.g. Atlas Pro 14"></label><div class="form-two"><label class="field-label">Price<input v-model="form.price" type="number" min="0" step="0.01" required placeholder="0.00"></label><label class="field-label">Stock<input v-model="form.stock" type="number" min="0" required placeholder="0"></label></div><label class="field-label">Category<select v-model="form.category_id" required><option disabled value="">Select a category</option><option v-for="category in categories" :key="category.id" :value="category.id">{{ category.name }}</option></select></label><label class="field-label">Description<textarea v-model="form.description" rows="4" placeholder="Describe what makes this product useful."></textarea></label><div class="image-upload"><input ref="fileInput" type="file" accept="image/jpeg,image/png" hidden @change="chooseImage"><button type="button" class="upload-zone" @click="fileInput?.click()"><img v-if="imagePreview" :src="imagePreview" alt="Product preview"><span v-else><ImagePlus :size="22" /><b>Choose product image</b><small>JPG or PNG, max 2 MB</small></span></button></div><div v-if="needsSpecs" class="spec-editor"><p class="eyebrow">REQUIRED HARDWARE SPECS</p><div class="form-two"><label class="field-label">CPU<input v-model="form.cpu" required></label><label class="field-label">RAM<input v-model="form.ram" required></label><label class="field-label">Storage<input v-model="form.storage" required></label><label class="field-label">Display<input v-model="form.display" required></label></div><label class="field-label">GPU<input v-model="form.gpu"></label><div class="form-two"><label class="field-label">Battery<input v-model="form.battery"></label><label class="field-label">Warranty<input v-model="form.warranty"></label></div></div><button class="button button-dark full-button" :disabled="saving"><Save :size="16" /> {{ saving ? 'Saving...' : editing ? 'Save changes' : 'Publish product' }}</button></form>
        </div>
    </section>
</template>
