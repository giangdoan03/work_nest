
// quy trình Hợp Đồng
export const CONTRACTS_STEPS = [
    { step_code: "contract_step_01", name: "Nhận nhu cầu khách hàng", department: ['Khách hàng'] },
    { step_code: "contract_step_02", name: "Đánh giá tính khả thi", department: ['P.KD, P.DVKT'] },
    { step_code: "contract_step_03", name: "Lập kế hoạch triển khai", department: ['P.KD, P.DVKT'] },
    { step_code: "contract_step_04", name: "Duyệt kế hoạch", department: ['Ban Giám đốc'] },
    { step_code: "contract_step_05", name: "Triển khai hồ sơ dự thầu", department: ['Ban Giám đốc , P.KD, P.DVKT, P.KHNS, P.TCKT'] },
    { step_code: "contract_step_06", name: "Chấm thầu", department: ['Khách hàng'] },
    { step_code: "contract_step_07", name: "Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)", department: ['P.KD'] },
    { step_code: "contract_step_08", name: "Triển khai ký hợp đồng bán", department: ['P.KD, P.TCKT, P.DVKT'] },
    { step_code: "contract_step_09", name: "Duyệt hợp đồng bán", department: ['Ban Giám đốc'] },
];

// quy trình Gói Thầu
export const BIDDING_STEPS = [
    { step_code: "bidding_step_01", name: "Đặt hàng NCC", department: ["P.KD, TP.M, TP.TCKT"] },
    { step_code: "bidding_step_02", name: "Duyệt đặt hàng", department: ["Ban Giám đốc"] },
    { step_code: "bidding_step_03", name: "Triển khai hợp đồng mua", department: ["P.TCKT, P.KD, P.DVKT"] },
    { step_code: "bidding_step_04", name: "Duyệt hợp đồng mua", department: ["Ban Giám đốc"] },
    { step_code: "bidding_step_05", name: "Thanh toán hợp đồng mua", department: ["P.TM, P.TCKT"] },
    { step_code: "bidding_step_06", name: "Kiểm tra hàng hóa", department: ["P.TM"] },
    { step_code: "bidding_step_07", name: "Nghiệm thu", department: ["P.TM, P.KD, P.DVKT"] },
    { step_code: "bidding_step_08", name: "Thông báo lỗi hàng", department: ["P.TM"] },
    { step_code: "bidding_step_09", name: "Nhập kho hàng hóa", department: ["P.KHNS, P.TCKT"] },
    { step_code: "bidding_step_10", name: "Xuất kho hàng hóa", department: ["P.KD, P.TCKT"] },
    { step_code: "bidding_step_11", name: "Duyệt phiếu xuất", department: ["Ban Giám đốc"] },
    { step_code: "bidding_step_12", name: "Giao hàng", department: ["P.KD, P.KHNS, P.TCKT"] },
    { step_code: "bidding_step_13", name: "Nghiệm thu từ phía KH", department: ["Khách hàng"] },
    { step_code: "bidding_step_14", name: "Xử lý sai lệch hoặc chứng từ", department: ["P.KD, P.DVKT, P.TMĐ"] },
    { step_code: "bidding_step_15", name: "Hỏi hồ sơ thanh quyết toán", department: ["P.KD, P.TM, P.TCKT"] },
    { step_code: "bidding_step_16", name: "Thanh toán", department: ["Khách hàng"] },
    { step_code: "bidding_step_17", name: "Thoả hồ sơ lưu chứng từ & kết thúc", department: ["P.KD, P.TCKT, P.TM, P.KHNS"] },

]
