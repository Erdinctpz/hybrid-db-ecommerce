var mongoose = require("mongoose")
var Schema = mongoose.Schema

var product = new Schema({
    // product_id kendi ayarlıyor
    supplier_id: Number,
    product_name: String,
    price: Number
})

const Product = mongoose.model("Products", product)

module.exports = Product