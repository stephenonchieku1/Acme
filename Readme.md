# Acme Widget Co - Shopping Basket System

A proof of concept shopping basket implementation for Acme Widget Co's new sales system.

## Overview

This system implements a shopping basket that handles:

- Product catalogue management
- Dynamic delivery cost calculation based on order value
- Special offers (currently "buy one red widget, get the second half price")
- Extensible architecture for future enhancements

## Assumptions Made

1. **Product codes are case-sensitive**: 'R01' is different from 'r01'
2. **Invalid product codes raise errors**: Adding non-existent products throws `ArgumentError`
3. **Offers apply automatically**: No need to activate offers manually
4. **Red widget offer applies optimally**: Always gives maximum discount possible
5. **Delivery rules are ordered**: Lower thresholds should come first in the array
6. **Monetary calculations**: Using Ruby's float arithmetic (sufficient for this proof of concept)
7. **Single offer per product type**: Currently only one offer can apply per product

## Product Catalogue

| Product | Code | Price |
|---------|------|-------|
| Red Widget | R01 | $32.95 |
| Green Widget | G01 | $24.95 |
| Blue Widget | B01 | $7.95 |

## Delivery Rules

- Orders under $50: $4.95 delivery
- Orders $50-$89.99: $2.95 delivery  
- Orders $90+: Free delivery

## Current Offers

- **Red Widget Special**: Buy one red widget, get the second half price
  - Applies to pairs of red widgets
  - For odd numbers, the extra widget is charged at full price

## Usage

### Basic Usage

```ruby
require_relative 'basket'

# Initialize the basket
products = {
  'R01' => 32.95,
  'G01' => 24.95,
  'B01' => 7.95
}

delivery_rules = [
  { threshold: 50, cost: 4.95 },
  { threshold: 90, cost: 2.95 }
]

offers = [
  {
    type: 'buy_one_get_second_half_price',
    product: 'R01'
  }
]

basket = Basket.new(products, delivery_rules, offers)

# Add items to basket
basket.add('R01')
basket.add('G01')

# Get total cost
total = basket.total
puts "Total: $#{'%.2f' % total}"
```

### Running Tests

The file includes built-in test cases that verify the expected behavior:

```bash
ruby basket.rb
```

This will run all test cases and display the results.

## Test Cases and Expected Results

| Items | Calculation | Expected Total |
|-------|-------------|----------------|
| B01, G01 | (7.95 + 24.95) + 4.95 delivery | $37.85 |
| R01, R01 | (32.95 + 16.48) + 4.95 delivery | $54.37 |
| R01, G01 | (32.95 + 24.95) + 2.95 delivery | $60.85 |
| B01, B01, R01, R01, R01 | (7.95×2 + 32.95 + 16.48 + 32.95) + 0 delivery | $98.27 |

## Architecture and Design Decisions

### Class Structure

The `Basket` class is initialized with three parameters:

- `product_catalogue`: Hash mapping product codes to prices
- `delivery_rules`: Array of hashes with threshold and cost
- `offers`: Array of offer configurations (extensible for future offers)

### Key Methods

- `add(product_code)`: Adds a product to the basket
- `total()`: Calculates the total cost including offers and delivery

### Offer Implementation

The red widget special offer is implemented by:

1. Counting red widgets in the basket
2. Calculating full-price widgets: `(count + 1) / 2` (rounds up)
3. Calculating half-price widgets: `count / 2` (rounds down)
4. Applying the discount and removing processed items from the count

### Delivery Cost Calculation

Delivery rules are processed in order of thresholds. The first rule where the subtotal is below the threshold applies. If no rule matches, delivery is free.

## Testing

The implementation includes comprehensive test cases that match the provided examples. All test cases pass and demonstrate the correct calculation of:

- Basic product pricing
- Delivery cost tiers
- Red widget special offer
- Complex combinations of products and offers

Run `ruby basket.rb` to execute all test cases and verify functionality.
