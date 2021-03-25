require 'chunky_png'
def to_rad(angle)
  angle / 180.0 * Math::PI
end
class Tree
  attr_accessor :leaf_points, :height, :width, :image, :iterations

  def initialize(filename: 'fractal.png', height: 2000, width: 3000, iterations: 15, leaf: Leaf, length: 200)
    self.image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::WHITE)
    self.iterations = iterations
    self.leaf_points = [leaf.new(x: width / 2, y: height / 2, heading: 270, length: length)]
  end

  def draw_fractal
    loop do
      break if iterations.zero?
      new_leaves = []
      leaf_points.each do |leaf|
        new_leaves << leaf.draw(image)
      end
      self.leaf_points = new_leaves.flatten
      self.iterations -= 1
    end
    image.save('temp.png')
  end
end

class Leaf
  ROTATION = 26
  SCALING = 0.83
  attr_accessor :heading, :length, :x, :y, :dx, :dy

  def initialize(x:, y:, heading:, length:)
    self.x = x
    self.y = y
    self.heading = heading
    self.length = length
    rads = to_rad(heading)
    self.dx = Math.cos(rads) * length + x
    self.dy = Math.sin(rads) * length + y
  end

  def child_leaves
    new_length = length * SCALING
    left_rotation = (heading + ROTATION) % 360
    right_rotation = (heading - ROTATION) % 360
    [Leaf.new(x: dx, y: dy, heading: left_rotation, length: new_length),
     Leaf.new(x: dx, y: dy, heading: right_rotation, length: new_length)]
  end

  def draw(image)
    image.line(x.to_i, y.to_i, dx.to_i, dy.to_i, ChunkyPNG::Color.from_hex('#aa007f'))
    child_leaves
  end

  private

  def to_rad(angle)
    angle / 180.0 * Math::PI
  end

end
class SplitLeaf < Leaf
  def child_leaves
    new_length = length * 0.85
    [SplitLeaf.new(x: dx, y: dy, heading: (heading - 25) % 360, length: new_length),
     SplitLeaf.new(x: (x + dx) / 2, y: (y + dy) / 2, heading: (heading - 25) % 360, length: new_length)]
  end
end
class Spiral < Leaf
  SCALING = 0.9
  ROTATION = 30

  def child_leaves
    new_length = length * SCALING
    [Spiral.new(x: dx, y: dy, heading: (heading - 5) % 360, length: new_length),
     Spiral.new(x: dx, y: dy, heading: (heading - 10) % 360, length: new_length),
     Spiral.new(x: dx, y: dy, heading: (heading - 40) % 360, length: new_length),
     Spiral.new(x: dx, y: dy, heading: (heading + 5) % 360, length: new_length),
     Spiral.new(x: dx, y: dy, heading: (heading + 10) % 360, length: new_length),
     Spiral.new(x: dx, y: dy, heading: (heading + 40) % 360, length: new_length)
    ]
  end

end
class Triangle
  attr_accessor :x, :x1, :x2, :x3, :y, :y1, :y2, :y3, :heading, :length
  # Something a little different. x & y in this case are the center of a triangle.
  # heading is the direction of the "top" point of a triangle, or 180deg to start.
  # length is the scale.
  def initialize(x:, y:, heading:, length:)
    self.x = x
    self.y = y
    self.heading = heading
    self.length = length
    rads = to_rad(heading)
    self.x1 = Math.cos(rads) * length + x
    self.y1 = Math.sin(rads) * length + y
    rads = to_rad(heading + 120)
    self.x2 = Math.cos(rads) * length + x
    self.y2 = Math.sin(rads) * length + y
    rads = to_rad(heading - 120)
    self.x3 = Math.cos(rads) * length + x
    self.y3 = Math.sin(rads) * length + y
  end

  def draw(image)
    puts [x1, y1, x2, y2, x3, y3].inspect
    image.line(x1.to_i, y1.to_i, x2.to_i, y2.to_i, ChunkyPNG::Color.from_hex('#FF0000'))
    image.line(x1.to_i, y1.to_i, x3.to_i, y3.to_i, ChunkyPNG::Color.from_hex('#00FF00'))
    image.line(x2.to_i, y2.to_i, x3.to_i, y3.to_i, ChunkyPNG::Color.from_hex('#0000FF'))
    child_leaves
  end

  def child_leaves
    [
      Triangle.new(x: (x1 + x2) / 2, y: (y1 + y2) / 2, heading: heading + 30, length: length * 0.5),
      Triangle.new(x: (x1 + x3) / 2, y: (y1 + y3) / 2, heading: heading + 150, length: length * 0.5),
      Triangle.new(x: (x3 + x2) / 2, y: (y3 + y2) / 2, heading: heading + 270, length: length * 0.5),
    ]
  end
end
Tree.new(leaf: Triangle, iterations: 8, length: 500).draw_fractal
