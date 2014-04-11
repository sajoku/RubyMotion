# Tagged pointers are only available on 64-bit platforms.
describe "ImmediateRef" do
  it "forwards messages to the wrapped tagged pointer object", :unless => bits == 64 do
    ref = NSIndexPath.indexPathWithIndex(42)
    ref.indexAtPosition(0).should == 42
    ref.should == NSIndexPath.indexPathWithIndex(42)
  end

  it "returns the tagged pointer object's class", :unless => bits == 64 do
    ref = NSIndexPath.indexPathWithIndex(42)
    ref.class.should == NSIndexPath
  end

  it "returns the tagged pointer object's methods", :unless => bits == 64 do
    ref = NSIndexPath.indexPathWithIndex(42)
    ref.methods(false).should == NSIndexPath.public_instance_methods(false)
  end

  it "returns the tagged pointer object's description", :unless => bits == 64 do
    ref = NSIndexPath.indexPathWithIndex(42)
    ref.inspect.should.match /#<ImmediateRef:0x\h+ <NSIndexPath: 0x\h+> \{length = 1, path = 42\}>/
  end

  it "stays an ImmediateRef when calling a Ruby method on it", :unless => bits == 64 do
    class NSIndexPath
      def ruby_instance_method
        self
      end
    end
    ref = NSIndexPath.indexPathWithIndex(42)
    ref.ruby_instance_method.should.eql ref
  end

  it "is able to dispatch methods to itself", :unless => bits == 64 do
    class NSIndexPath
      def ruby_instance_method
        self.indexAtPosition(0)
      end
    end
    ref = NSIndexPath.indexPathWithIndex(42)
    ref.ruby_instance_method.should == 42
  end
end