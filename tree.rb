require 'chunky_png'
class Tree
  attr_accessor :leaf_points, :height, :width, :image, :iterations

  def initialize(filename: 'fractal.png', height: 2000, width: 2000, iterations: 15, leaf: Leaf)
    self.image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
    self.iterations = iterations
    self.leaf_points = [leaf.new(x: width / 2, y: 20, heading: 90, length: height / 8)]
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

class Spiral < Leaf
  SCALING = 0.9
  ROTATION = 30

  def child_leaves
    new_length = length * SCALING
    left_rotation = (heading - ROTATION) % 360
    right_rotation = (heading - ROTATION / 2) % 360
    [Spiral.new(x: dx, y: dy, heading: left_rotation, length: new_length),
     Spiral.new(x: dx, y: dy, heading: right_rotation, length: new_length)]
  end

end

Tree.new.draw_fractal
