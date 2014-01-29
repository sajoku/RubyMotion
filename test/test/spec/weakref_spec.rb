describe "WeakRef" do
  it "creates proxy objects that forward messages" do
    ary = [1, 2, 3]
    ref = WeakRef.new(ary)
    ref.class.should == Array

    ref[0].should == 1
    ref[1].should == 2
    ref[2].should == 3
    ref.should == ary

    1.should == ref[0]
    2.should == ref[1]
    3.should == ref[2]
    ary.should == ref

    WeakRef.new('a').should < WeakRef.new('b')
  end

  it "creates proxy objects that forward respond_to?" do
    ary = [1, 2, 3]
    ref = WeakRef.new(ary)
    ary.methods.each { |x| ref.respond_to?(x).should == true }
  end

  it "creates weak references" do
    obj = Object.new
    rc = obj.retainCount
    ref = WeakRef.new(obj)
    obj.retainCount.should == rc
  end

  it "passes the internal reference when given to ObjC APIs" do
    ary = [1, 2, 3]
    ref = WeakRef.new(ary)
    ary2 = NSArray.arrayWithArray(ref)
    ary2.should == ary
  end

  xit "cannot be subclassed" do
    lambda { class Foo < WeakRef; end }.should.raise(RuntimeError)
  end

  it "is destroyed like regular objects" do
    $weakref_destroyed = false
    autorelease_pool do
      obj = Object.new
      ref = WeakRef.new(obj)
      ObjectSpace.define_finalizer(ref, proc { $weakref_destroyed = true })
    end
    $weakref_destroyed.should == true
  end

  it "responds to #weakref_alive? (which is special cased in the dispatcher)" do
    WeakRef.new(Object.new).respond_to?(:weakref_alive?).should == true
  end

  it "returns whether or not the reference is still alive" do
    autorelease_pool do
      @ref = WeakRef.new(Object.new)
      @ref.weakref_alive?.should == true
    end
    wait 0.1 do
      @ref.weakref_alive?.should == false
    end
  end

  it "raises a WeakRef::RefError if messaged when the reference is no longer alive" do
    autorelease_pool do
      @ref = WeakRef.new(Object.new)
      lambda { @ref.to_s }.should.not.raise
    end
    wait 0.1 do
      lambda { @ref.to_s }.should.raise(WeakRef::RefError)
    end
  end

  it "can be nested" do
    obj = Object.new
    ref1 = WeakRef.new(obj)
    ref2 = WeakRef.new(ref1)
    ref3 = WeakRef.new(ref2)
    ref1.object_id.should == obj.object_id
    ref2.object_id.should == obj.object_id
    ref3.object_id.should == obj.object_id
  end

  it "is resolved by NSObject#==" do
    vc = UIViewController.new
    ref = WeakRef.new(vc)
    ref.should == vc
    vc.should == ref
  end

  it "is resolved by Boxed#==" do
    rect = CGRect.new(CGPoint.new(1, 2), CGSize.new(3, 4))
    ref = WeakRef.new(rect)
    ref.should == rect
    rect.should == ref
  end
end

describe "Proc#weak!" do
  it "sets ->self to a weak-reference" do
    rc = retainCount
    b1 = Proc.new {}.weak!
    retainCount.should == rc
    b2 = Proc.new {}
    retainCount.should == rc + 1
  end

  it "returns a reference to the Proc object" do
    b = Proc.new {}
    b.weak!.should == b
  end

  it "can safely be called multiple times" do
    b = Proc.new {}.weak!
    rc = retainCount
    i = 0; while i < 100; b.weak!; i += 1; end
    rc.should == retainCount
  end
end
