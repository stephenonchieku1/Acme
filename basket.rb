class Basket
#i have initiliazed the class with the product catalogue, delivery rules, and offers
    def initialize(product_catalogue, delivery_rules, offers)
      @product_catalogue = product_catalogue
      @delivery_rules = delivery_rules
      @offers = offers
      @items = []
    end
  
    def add(product_code)
      raise ArgumentError, "Product #{product_code} not found" unless @product_catalogue.key?(product_code)
      @items << product_code
    end
  
    def total
      subtotal = calculate_subtotal_with_offers
      delivery_cost = calculate_delivery_cost(subtotal)
      subtotal + delivery_cost
    end
  
  private
  
    def calculate_subtotal_with_offers
      item_counts = count_items
      subtotal = 0
  
      # Apply "buy one red widget, get the second half price" offer
      if item_counts['R01'] && item_counts['R01'] >= 2
        red_widgets = item_counts['R01']
        full_price_widgets = (red_widgets + 1) / 2 
        half_price_widgets = red_widgets / 2        
        
        red_widget_cost = (full_price_widgets * @product_catalogue['R01']) + 
                         (half_price_widgets * @product_catalogue['R01'] * 0.5)
        subtotal += red_widget_cost
        item_counts.delete('R01')  # Remove processed red widgets
      end
  
      # Add remaining items at full price
      item_counts.each do |product_code, quantity|
        subtotal += quantity * @product_catalogue[product_code]
      end
  
      subtotal
    end
  
    def calculate_delivery_cost(subtotal)
      @delivery_rules.each do |rule|
        return rule[:cost] if subtotal < rule[:threshold]
      end
      0  # Free delivery if no rules match (subtotal >= highest threshold)
    end
  
    def count_items
      @items.each_with_object(Hash.new(0)) { |item, counts| counts[item] += 1 }
    end
  end
  
  # Example usage and test cases
  if __FILE__ == $0
    # Product catalogue
    products = {
      'R01' => 32.95,  # Red Widget
      'G01' => 24.95,  # Green Widget  
      'B01' => 7.95    # Blue Widget
    }
  
    # Delivery rules (in ascending order of thresholds)
    delivery_rules = [
      { threshold: 50, cost: 4.95 },
      { threshold: 90, cost: 2.95 }
      # Orders >= 90 get free delivery (handled by returning 0 when no rules match)
    ]
  
    # Offers (extensible for future offers)
    offers = [
      {
        type: 'buy_one_get_second_half_price',
        product: 'R01'
      }
    ]
  
    # Create basket instance
    basket = Basket.new(products, delivery_rules, offers)
  
    # Test cases
    puts "Testing Acme Widget Co Basket System"
    puts "=" * 40
  
    # Test case 1: B01, G01
    basket1 = Basket.new(products, delivery_rules, offers)
    basket1.add('B01')
    basket1.add('G01')
    puts "Test 1 - B01, G01: $#{'%.2f' % basket1.total} (Expected: $37.85)"
  
    # Test case 2: R01, R01  
    basket2 = Basket.new(products, delivery_rules, offers)
    basket2.add('R01')
    basket2.add('R01')
    puts "Test 2 - R01, R01: $#{'%.2f' % basket2.total} (Expected: $54.38)"
  
    # Test case 3: R01, G01
    basket3 = Basket.new(products, delivery_rules, offers)
    basket3.add('R01')
    basket3.add('G01')
    puts "Test 3 - R01, G01: $#{'%.2f' % basket3.total} (Expected: $60.85)"
  
    # Test case 4: B01, B01, R01, R01, R01
    basket4 = Basket.new(products, delivery_rules, offers)
    basket4.add('B01')
    basket4.add('B01')
    basket4.add('R01')
    basket4.add('R01')
    basket4.add('R01')
    puts "Test 4 - B01, B01, R01, R01, R01: $#{'%.2f' % basket4.total} (Expected: $98.28)"
  
    puts "=" * 40
    puts "All tests completed!"
  end