var mongoose = require("mongoose")
const Product = require("./productSchema")
var Schema = mongoose.Schema

var cart = new Schema({
    customer_id: Number,
    products: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Products'}],
    total_price: Number
})

const Cart = mongoose.model("Carts", cart)

module.exports = Cart