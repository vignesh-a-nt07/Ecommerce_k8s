const prisma = require("./utills/db");

async function seedDatabase() {
  const { nanoid } = await import("nanoid");
  try {
    console.log("Seeding database...");

    // Create or use existing merchant
    let merchant = await prisma.merchant.findFirst();
    if (!merchant) {
      merchant = await prisma.merchant.create({
        data: {
          id: nanoid(),
          name: "Tech Store",
          email: "merchant@techstore.com",
          phone: "+123456789",
          address: "123 Tech Street",
          status: "ACTIVE",
        },
      });
      console.log("Merchant created:", merchant.id);
    } else {
      console.log("Using existing merchant:", merchant.id);
    }

    // Get or create categories
    const categoryNames = ["Smartphones", "Laptops", "Headphones"];
    const categories = {};

    for (const name of categoryNames) {
      let category = await prisma.category.findFirst({
        where: { name },
      });
      if (!category) {
        category = await prisma.category.create({
          data: {
            id: nanoid(),
            name,
          },
        });
      }
      categories[name] = category.id;
      console.log("Category ready:", name, category.id);
    }

    // Create products
    const products = [
      {
        title: "Samsung Galaxy S24 Ultra",
        price: 15999999,
        description: "Smartphone flagship dengan kamera 200MP dan S Pen",
        manufacturer: "Samsung",
        categoryId: categories["Smartphones"],
        inStock: 50,
        mainImage: "/samsung-s24.jpg",
        rating: 5,
      },
      {
        title: "iPhone 15 Pro Max",
        price: 17999999,
        description:
          "iPhone terbaru dengan chip A17 Pro dan kamera titanium",
        manufacturer: "Apple",
        categoryId: categories["Smartphones"],
        inStock: 30,
        mainImage: "/iphone-15.jpg",
        rating: 5,
      },
      {
        title: "MacBook Pro M3",
        price: 25999999,
        description: "Laptop untuk profesional dengan chip M3 yang powerful",
        manufacturer: "Apple",
        categoryId: categories["Laptops"],
        inStock: 20,
        mainImage: "/macbook-m3.jpg",
        rating: 4,
      },
      {
        title: "Sony WH-1000XM5",
        price: 4999999,
        description: "Headphone noise cancelling terbaik dari Sony",
        manufacturer: "Sony",
        categoryId: categories["Headphones"],
        inStock: 75,
        mainImage: "/sony-wh1000xm5.jpg",
        rating: 4,
      },
    ];

    const createdProducts = await Promise.all(
      products.map((product) =>
        prisma.product.create({
          data: {
            id: nanoid(),
            slug: product.title
              .toLowerCase()
              .replace(/\s+/g, "-")
              .replace(/[^\w-]/g, ""),
            ...product,
            merchantId: merchant.id,
          },
        })
      )
    );

    console.log("Products created:", createdProducts.map((p) => p.title));
    console.log("✅ Database seeded successfully!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error seeding database:", error);
    process.exit(1);
  }
}

seedDatabase();
