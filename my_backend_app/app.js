require('dotenv').config();
const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const mysql = require('mysql');
const jwt = require('jsonwebtoken');
const secretKey = process.env.JWT_SECRET
const port = process.env.PORT || 3000;

const Roles = {
    CUSTOMER: 0,
    SUPPLIER: 1,
};

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

//connect mysql database
let conn = mysql.createConnection({
    host : process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE
})


conn.connect((err) => {
    if (err) {
      console.error('MySQL bağlantı hatası: ', err);
      return;
    }
    console.log('MySQL veritabanına bağlanıldı');
  });


app.get('/', (req, res) => {
    return res.json({
        message: 'Welcome to RESTfull api with node js.'
    });
})

function authenticate(allowedRoles) {
    return function (req, res, next) {
        const authHeader = req.headers['authorization'];

        if (!authHeader) {
            return res.status(401).json({ message: "No token provided" });
        }

        const token = authHeader.split(' ')[1];
        try {
            const decoded = jwt.verify(token, "SECRET");
            req.user = decoded;

            if (allowedRoles.includes(decoded.role)) {
                next();
            } else {
                res.status(403).json({ message: "Access denied: role not allowed" });
            }
        } catch (err) {
            res.status(401).json({ message: "Invalid token" });
        }
    };
}

/* ------------------------------ MySQL ------------------------------ */
app.post('/login', (req, res) => {
    const username = req.body.username
    const password = req.body.password
    const role = req.body.role
    
    const values = [username, password, role]
    conn.query('SELECT user_id, role FROM users WHERE username = ? AND password = ? AND role = ? LIMIT 1', values, (error, results) => {
        if (error) {
            return res.status(500).json({ message: "Database error", success: false });
        }
        
        if (!(results.length == 0)) {
            const role = results[0].role
            const user_id = results[0].user_id

            const token = jwt.sign({user_id: user_id , role: role}, secretKey)
            if(token) {
                res.status(200).json({token: token})
            }
            else {
                res.status(401).json({message: "Authentication Failed", success: false})
            }
        }
        else {
            res.status(401).json({message: "Authentication Failed", success: false})
        }
    })
})

app.get('/users', (req, res) => {
    conn.query("SELECT * FROM users", (error, results) => {
        if (error) throw error;

        let message = ""
        if (results === undefined || results.length == 0) {
            message = "post is empty";
        } else {
            message = "Successfully retrived all users";
        }

        return res.json({
            data: results
        });
    })
})

app.post('/createUser', (req, res) => {
    const username = req.body.username
    const password = req.body.password
    const role = req.body.role

    conn.query("SELECT username FROM users WHERE username = ?", username, (error, results) => {
        if (error) {
            console.error(error);
            return res.status(500).json({success: false, message: "An error occurred while adding the user." });
        }

        if (results[0] == undefined) {
            const values = [username, password, role]
            conn.query("INSERT INTO users(username, password, role) VALUES(?, ?, ?)", values, (error, results) => {
                if (error) {
                    console.error(error);
                    return res.status(500).json({success: false, message: "An error occurred while adding the user." });
                }
                
                return res.status(200).json({success: true, message: "Successfully created user" })
            })
        }
        else {
            return res.status(409).json({success: false, message: "Username is exist already"})
        }
    })
})

app.post('/getUserInfo', authenticate([Roles.CUSTOMER, Roles.SUPPLIER]), (req, res) => {
    const user_id = req.user.user_id

    conn.query(
        "SELECT username, password FROM users WHERE user_id = ?", 
        [user_id],
        (error, results) => {
            if (error) return res.status(500).json({ success: false, message: "Database error", error });
            if (!results.length) return res.status(404).json({ success: false, message: "User not found" });

            return res.status(200).json({ 
                success: true,
                data: results[0]
            })
        }
    )
})

app.post('/updateUserInfo', authenticate([Roles.CUSTOMER, Roles.SUPPLIER]), (req, res) => {
    const user_id = req.user.user_id
    const username = req.body.username
    const password = req.body.password

    const values = [username, password, user_id]

    conn.query(
        "UPDATE users SET username = ?, password = ? WHERE user_id = ?",
        values,
        (error, results) => {
            if (error) return res.status(500).json({ success: false, message: "Database error", error });
            
            return res.status(200).json({
                success: true,
                message: "User updated!"
            })
        }
    )
})


/* ------------------------------ MongoDB ------------------------------ */

const mongoose = require("mongoose")

var Product = require("./productSchema");
var Cart = require("./cartSchema")

//connect mongodb
mongoose.connect(process.env.MONGODB_URI)

mongoose.connection.once("open", () => {
    console.log("Connected to mongodb!")
}).on("error", (error) => {
    console.log("Failed to connect mongodb " + error)
})


/* --------------- Supplier --------------- */

app.get("/fetchProducts", authenticate([Roles.SUPPLIER]), async(req, res) => {
    try {
        const supplier_id = req.user.user_id
        const products = await Product.find({ supplier_id: supplier_id})

        res.status(200).json({
            success: true,
            data: products
        });
    }
    catch {
        res.status(500).json({
            success: false,
            message: 'Sunucuda bir hata oluştu.'
        });
    }
});

app.post("/addProduct", authenticate([Roles.SUPPLIER]), (req, res) => {
    try {
        const product = new Product({
            supplier_id: req.user.user_id,
            product_name: req.body.product_name,
            price: req.body.price
        })

        product.save().then(() => {
            if (!product.isNew) {
                res.status(200).json({ message: "Succesfuly added!"})
            }
            else {
                res.status(400).json({ message: "Failed to add product"})
            }
        }).catch((err) => {
            console.error(err);
            res.status(500).json({ message: "An error occurred while saving the product." });
        });
        
    }
    catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
})

app.post('/updateProduct', authenticate([Roles.SUPPLIER]), (req, res) => {
    Product.findOneAndUpdate(
        { _id: req.body._id },
        {
            product_name: req.body.product_name,
            price: req.body.price
        },
        { new: true }
    )
    .then(result => {
        if (result) {
            res.status(200).send({ message: 'Product updated successfully!', data: result });
        } else {
            res.status(404).send({ message: 'Product not found!' });
        }
    })
    .catch(err => {
        res.status(500).send({ message: 'Update failed', error: err });
    });
})

app.post('/deleteProduct', authenticate([Roles.SUPPLIER]), async (req, res) => {
    try {
        const user_id = req.user.user_id
        const product_id =  req.body._id

        // 1. Delete the product
        const result = await Product.findOneAndDelete({ _id: product_id, supplier_id: user_id });
        if (result) {
            const productPrice = result.price;

            // 2. Remove the product from carts
            await Cart.updateMany(
                { products: product_id },
                { $inc: { total_price: -productPrice } }
            );
            
            await Cart.updateMany(
                { products: product_id },
                { $pull: { products: product_id } }
            );
                      

            res.status(200).json({ message: 'The product was deleted successfully'});
        } else {
            res.status(404).json({ message: 'Product not found.' });
        }
    } catch (err) {
        console.error('Error:', err);
        res.status(500).json({ message: 'An error occurred while deleting the product.', error: err });
    }
});


/* --------------- Supplier --------------- */


/* --------------- Customer --------------- */

app.get('/allProducts', (req, res) => {
    const products = Product.find().then((products) => {
        res.status(200).json({
            success: true, 
            data: products
        })
    })
    .catch(err => {
        res.status(500).send({
            success: false,
            message: 'An error occurred while fetching products.', 
            error: err 
        });
    });
})

app.post('/addToCart', authenticate([Roles.CUSTOMER]), async (req, res) => {
    try {
        const customer_id = req.user.user_id
        const product_id = req.body._id
    
        if (!product_id) {
            return res.status(400).json({
                success: false,
                message:'Product ID is required.'
            });
        }

        const product = await Product.findById(product_id)
        if (!product) return res.status(404).json({
            success: false, 
            message:'Product not found'
        });

        let cart = await Cart.findOne({ customer_id: customer_id})

        if (!cart) {
             cart = new Cart({
                customer_id: customer_id,
                products: [product._id],
                total_price: product.price
            });
        }
        else {
            let isExist = cart.products.map(id => id.toString()).includes(product._id.toString())
            if (isExist) { return }

            cart.products.push(product._id)
            cart.total_price += product.price
        }

        await cart.save();
        res.status(200).json({ 
            success: true,
            message: 'Product added to cart.' 
        });
    }
    catch (err) {
        console.error(err);
        res.status(500).json({ 
            success: false,
            message: 'Server error' 
        });
    }  
});

app.get('/getCart', authenticate([Roles.CUSTOMER]), async (req, res) => {
    try {
        const customer_id = req.user.user_id
        const cart = await Cart.findOne({ customer_id: customer_id })
        res.status(200).json({
            success: true,
            cart: cart
        });
    }
    catch {
        res.status(500).json({
            success: false,
            message: 'Server Error.'
        });
    }
});

function checkTotalPrice(cart) {
    let total = 0;
    cart.products.forEach(product => {
        total += product.price;
    });
    cart.total_price = total;
    return cart;
}

app.get('/getCartWithPopulate', authenticate([Roles.CUSTOMER]), async (req, res) => {
    try {
        const customer_id = req.user.user_id
        let cart = await Cart.findOne({ customer_id: customer_id }).populate('products')

        if (cart) {
            cart = checkTotalPrice(cart)
        }

        res.status(200).json({
            success: true,
            cart: cart
        });
    }
    catch {
        res.status(500).json({
            success: false,
            message: 'Server Error'
        });
    }
});

app.post('/removeProductFromCart', authenticate([Roles.CUSTOMER]), async (req, res) => {
    const customer_id = req.user.user_id
    const product_id = req.body._id

    try {
        const cart = await Cart.findOne({ customer_id: customer_id })
        const product = await Product.findById(product_id)

        const index = cart.products.findIndex(
            id => id.toString() === product_id
          );
          
          if (index > -1) {
            cart.products.splice(index, 1);
            cart.total_price -= product.price;
            await cart.save();
            return res.status(200).json({ success: true, message: "Product removed from cart." });
          }
          else {
            return res.status(400).json({ success: false, message: "Product not found" });
          }
    }
    catch (err) {
        console.error(err);
        return res.status(500).json({ success: false, message: "An error occurred while removing the product from the cart." });
    }
})

app.post('/clearCart', authenticate([Roles.CUSTOMER]), async (req, res) => {
    const customer_id = req.user.user_id

    try {
        const result = await Cart.findOneAndDelete({ customer_id: customer_id })
        if (result) {
            res.status(200).json({ 
                success: true,
                message: 'The Cart was deleted successfully.' 
            });
        } 
        else {
            res.status(404).json({ 
                success: false,
                message: 'Cart not found.' 
            });
        }
    }
    catch (err) {
        res.status(500).json({ 
            success: false,
            message: 'An error occurred while deleting the cart.', error: err 
        });
    }
});

/* --------------- Customer --------------- */




app.listen(port, () => {
    console.log("Listening on port %d", port);
})

module.exports = app;