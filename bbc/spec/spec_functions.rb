def spec_before
  Products.dataset.delete
  Products.insert(
    productId: 1,
    ProductName: "Old Coffee",
    StockQuantity: 10,
    Price: 10.00,
    ProductImage: "old.jpg",
    ProductDescription: "Old desc"
  )
end
