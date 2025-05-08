<?php

namespace App\Controllers;

use App\Models\ProductModel;
use App\Models\ProductAttributeModel;
use CodeIgniter\RESTful\ResourceController;

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

use App\Traits\AuthTrait;

class ProductController extends ResourceController
{
    protected $format = 'json';

    use AuthTrait; // 👈 Dùng trait

    private function validateProduct($data)
    {
        $rules = [
            'name' => 'required|min_length[3]',
            'sku' => 'required',
            'price' => 'required|decimal',
        ];

        if (!$this->validate($rules)) {
            return $this->failValidationErrors($this->validator->getErrors());
        }

        return true;
    }

    public function index()
    {
        $userId = $this->getUserId(); // Dùng được ngay

        log_message('debug', 'SESSION USER_ID in index: ' . $userId);

        $productModel = new ProductModel();
        $perPage = $this->request->getGet('per_page') ?? 10;
        $page = $this->request->getGet('page') ?? 1;
        $search = $this->request->getGet('search');

        $builder = $productModel->where('deleted_at', null)
            ->where('user_id', $userId); // 👈 Lọc theo user

        if ($search) {
            $builder->groupStart()
                ->like('name', $search)
                ->orLike('sku', $search)
                ->groupEnd();
        }

        $products = $builder->paginate($perPage, 'default', $page);

        foreach ($products as &$product) {
            $product['attributes'] = (new ProductAttributeModel())
                ->where('product_id', $product['id'])
                ->findAll();
        }

        return $this->respond([
            'data' => $products,
            'pager' => $productModel->pager->getDetails(),
        ]);
    }


    public function show($id = null)
    {
        $userId = $this->getUserId(); // Dùng được ngay

        $productModel = new ProductModel();
        $product = $productModel->getProductWithAttributes($id);

        if (!$product) {
            return $this->failNotFound('Product not found');
        }

        // Kiểm tra quyền sở hữu sản phẩm
        if ($product['user_id'] != $userId) {
            return $this->failForbidden('Bạn không có quyền xem sản phẩm này');
        }

        return $this->respond($product);
    }


    public function create()
    {
        $userId = $this->getUserId();

        $productModel = new ProductModel();
        $attributeModel = new ProductAttributeModel();

        $data = $this->request->getJSON(true);

        // Validate
        $validationResult = $this->validateProduct($data);
        if ($validationResult !== true) {
            return $validationResult;
        }

        // Chuẩn bị data sản phẩm
        $productData = [
            'sku' => $data['sku'] ?? null,
            'name' => $data['name'] ?? null,
            'category_id' => $data['category_id'] ?? null,
            'price' => $data['price'] ?? null,
            'price_from' => $data['price_from'] ?? null,
            'price_to' => $data['price_to'] ?? null,
            'show_contact_price' => !empty($data['show_contact_price']) ? 1 : 0,
            'description' => $data['description'] ?? null,
            'status' => !empty($data['status']) ? 1 : 0,
            'created_at' => date('Y-m-d H:i:s'),
            'updated_at' => date('Y-m-d H:i:s'),
            'display_settings' => json_encode($data['display_settings'] ?? []),
            'user_id' => $userId, // 👈 Gán user_id vào sản phẩm
        ];

        // Encode các field mảng
        $arrayFields = ['avatar', 'image', 'video', 'certificate_file', 'attributes'];
        foreach ($arrayFields as $field) {
            $productData[$field] = json_encode($data[$field] ?? []);
        }

        // Insert sản phẩm
        $productId = $productModel->insert($productData);

        // Insert attributes nếu có
        if (!empty($data['attributes']) && is_array($data['attributes'])) {
            foreach ($data['attributes'] as $attribute) {
                if (!empty($attribute['name']) && !empty($attribute['value'])) {
                    $attributeModel->insert([
                        'product_id' => $productId,
                        'name' => $attribute['name'],
                        'value' => $attribute['value'],
                        'created_at' => date('Y-m-d H:i:s'),
                        'updated_at' => date('Y-m-d H:i:s'),
                    ]);
                }
            }
        }

        $product = $productModel->find($productId);
        return $this->respondCreated([
            'status' => 'success',
            'message' => 'Tạo sản phẩm thành công',
            'data' => $product
        ]);
    }


    public function update($id = null)
    {
        $session = session();
        $userId = $session->get('user_id'); // 👈 Lấy user_id từ session

        $productModel = new ProductModel();
        $attributeModel = new ProductAttributeModel();

        $data = $this->request->getJSON(true);

        // Kiểm tra quyền sở hữu sản phẩm
        $product = $productModel->find($id);
        if (!$product) {
            return $this->failNotFound('Sản phẩm không tồn tại');
        }
        if ($product['user_id'] != $userId) {
            return $this->failForbidden('Bạn không có quyền sửa sản phẩm này');
        }

        // Validate dữ liệu đầu vào
        $validationResult = $this->validateProduct($data);
        if ($validationResult !== true) {
            return $validationResult;
        }

        // Chuẩn bị dữ liệu cập nhật
        $productData = [
            'sku' => $data['sku'] ?? null,
            'name' => $data['name'] ?? null,
            'category_id' => $data['category_id'] ?? null,
            'price_mode' => $data['price_mode'] ?? 'single',
            'price' => $data['price'] ?? null,
            'price_from' => $data['price_from'] ?? null,
            'price_to' => $data['price_to'] ?? null,
            'show_contact_price' => !empty($data['show_contact_price']) ? 1 : 0,
            'description' => $data['description'] ?? null,
            'status' => !empty($data['status']) ? 1 : 0,
            'updated_at' => date('Y-m-d H:i:s'),
        ];

        // Encode các field mảng thành JSON string
        $arrayFields = ['avatar', 'image', 'video', 'certificate_file', 'attributes'];
        foreach ($arrayFields as $field) {
            $productData[$field] = json_encode($data[$field] ?? []);
        }

        if (!empty($data['display_settings'])) {
            $productData['display_settings'] = is_array($data['display_settings'])
                ? json_encode($data['display_settings'])
                : $data['display_settings'];
        }

        // Cập nhật sản phẩm
        $productModel->update($id, $productData);

        // Cập nhật thuộc tính sản phẩm
        if (!empty($data['attributes']) && is_array($data['attributes'])) {
            $attributeModel->where('product_id', $id)->delete();

            foreach ($data['attributes'] as $attribute) {
                if (!empty($attribute['name']) && !empty($attribute['value'])) {
                    $attributeModel->insert([
                        'product_id' => $id,
                        'name' => $attribute['name'],
                        'value' => $attribute['value'],
                        'created_at' => date('Y-m-d H:i:s'),
                        'updated_at' => date('Y-m-d H:i:s'),
                    ]);
                }
            }
        }

        return $this->respond(['message' => 'Cập nhật sản phẩm thành công']);
    }


    public function toggleStatus($id = null)
    {
        $session = session();
        $userId = $session->get('user_id'); // 👈 Lấy user_id từ session

        $productModel = new ProductModel();
        $data = $this->request->getJSON(true);

        // Kiểm tra status hợp lệ
        if (!isset($data['status'])) {
            return $this->failValidationErrors('Thiếu trạng thái');
        }

        // Kiểm tra sản phẩm có tồn tại và thuộc user này không
        $product = $productModel->find($id);
        if (!$product) {
            return $this->failNotFound('Sản phẩm không tồn tại');
        }
        if ($product['user_id'] != $userId) {
            return $this->failForbidden('Bạn không có quyền thay đổi trạng thái sản phẩm này');
        }

        // Cập nhật trạng thái
        $productModel->update($id, [
            'status' => $data['status'] ? 1 : 0,
            'updated_at' => date('Y-m-d H:i:s')
        ]);

        return $this->respond(['message' => 'Cập nhật trạng thái thành công']);
    }


    public function delete($id = null)
    {
        $productModel = new ProductModel();
        $attributeModel = new ProductAttributeModel();

        // Delete attributes cứng
        $attributeModel->where('product_id', $id)->delete();

        // Soft delete product
        $productModel->delete($id);

        return $this->respondDeleted(['message' => 'Product soft deleted successfully']);
    }

    public function export()
    {
        $productModel = new ProductModel();
        $products = $productModel->where('deleted_at', null)->findAll();

        foreach ($products as &$product) {
            $product['attributes'] = (new ProductAttributeModel())
                ->where('product_id', $product['id'])
                ->findAll();
        }

        $filename = 'products_export_' . date('YmdHis') . '.json';
        $data = json_encode($products, JSON_PRETTY_PRINT);

        return $this->response
            ->setHeader('Content-Type', 'application/json')
            ->setHeader('Content-Disposition', 'attachment; filename="' . $filename . '"')
            ->setBody($data);
    }

    public function import()
    {
        $file = $this->request->getFile('file');

        if (!$file->isValid()) {
            return $this->fail('Invalid file upload.');
        }

        $data = json_decode(file_get_contents($file->getTempName()), true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return $this->fail('Invalid JSON format.');
        }

        $productModel = new ProductModel();
        $attributeModel = new ProductAttributeModel();

        foreach ($data as $item) {
            // Insert product
            $productData = $item;
            unset($productData['attributes']);
            $productId = $productModel->insert($productData);

            // Insert attributes
            if (!empty($item['attributes'])) {
                foreach ($item['attributes'] as $attribute) {
                    $attributeModel->insert([
                        'product_id' => $productId,
                        'name' => $attribute['name'],
                        'value' => $attribute['value'],
                    ]);
                }
            }
        }

        return $this->respond(['message' => 'Products imported successfully']);
    }

    public function exportExcel()
    {
        $productModel = new ProductModel();
        $products = $productModel->where('deleted_at', null)->findAll();

        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();

        // Headers
        $sheet->setCellValue('A1', 'ID');
        $sheet->setCellValue('B1', 'Name');
        $sheet->setCellValue('C1', 'SKU');
        $sheet->setCellValue('D1', 'Price');
        $sheet->setCellValue('E1', 'Attributes');

        $row = 2;
        foreach ($products as $product) {
            $attributes = (new ProductAttributeModel())
                ->where('product_id', $product['id'])
                ->findAll();

            $attributeText = '';
            foreach ($attributes as $attribute) {
                $attributeText .= "{$attribute['name']}: {$attribute['value']}; ";
            }

            $sheet->setCellValue("A{$row}", $product['id']);
            $sheet->setCellValue("B{$row}", $product['name']);
            $sheet->setCellValue("C{$row}", $product['sku']);
            $sheet->setCellValue("D{$row}", $product['price']);
            $sheet->setCellValue("E{$row}", $attributeText);

            $row++;
        }

        $writer = new Xlsx($spreadsheet);
        $filename = 'products_export_' . date('YmdHis') . '.xlsx';

        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header("Content-Disposition: attachment; filename=\"{$filename}\"");
        $writer->save('php://output');
        exit;
    }

    public function restore($id = null)
    {
        $productModel = new ProductModel();
        $product = $productModel->onlyDeleted()->find($id);

        if (!$product) {
            return $this->failNotFound('Product not found or not deleted.');
        }

        $productModel->update($id, ['deleted_at' => null]);

        return $this->respond(['message' => 'Product restored successfully']);
    }

    public function exportSelected()
    {
        $ids = $this->request->getJSON(true)['ids'] ?? [];

        if (empty($ids)) {
            return $this->failValidationErrors('No product IDs provided.');
        }

        $productModel = new ProductModel();
        $products = $productModel->whereIn('id', $ids)->findAll();

        foreach ($products as &$product) {
            $product['attributes'] = (new ProductAttributeModel())
                ->where('product_id', $product['id'])
                ->findAll();
        }

        $filename = 'selected_products_export_' . date('YmdHis') . '.json';
        $data = json_encode($products, JSON_PRETTY_PRINT);

        return $this->response
            ->setHeader('Content-Type', 'application/json')
            ->setHeader('Content-Disposition', 'attachment; filename="' . $filename . '"')
            ->setBody($data);
    }


}
