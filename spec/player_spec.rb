describe P4::Chips::Player do
  it "should be a module" do
    expect(P4::Chips::Player.class).to eql Module
  end

  it "object to mixin to should respond to :id" do
    expect do
      class Player
        include P4::Chips::Player
      end
    end.to_not raise_error(Exception)
  end

  it "should mixin instance methods" do
    class Player
      include P4::Chips::Player
    end

    expect(Player.new.respond_to? :balance).to be true
  end
end
