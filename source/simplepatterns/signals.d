/**
	A simple implementation of the signals pattern.
*/
module simplepatterns.signals;

import std.algorithm;

version(unittest)
{
	import fluent.asserts;
}

/**
	The implementation of the signals pattern.
*/
struct Signals(Slot)
{
	/**
		Adds a function/delegate to the array of functions/delegates to be called later.

		Params:
			slot = The function/delegate to add.
	*/
	void connect(Slot slot)
	{
		slots_ ~= slot;
	}

	/**
		Remove a function/delegate from the array of functions/delegates.

		Params:
			slot = The function/delegate to remove.
	*/
	void disconnect(Slot slot)
	{
		slots_ = slots_.remove!((Slot a) { return a is slot; });
	}

	/**
		Removes all stored delegates/functions from the signals array.
	*/
	void disconnectAll()
	{
		slots_ = [];
	}

	/**
		Calls all functions/delegates in the signals array.
	*/
	void emit(Args...)(Args args)
	{
		slots_.each!(a => a(args));
	}

private:
	Slot[] slots_;
}

///
unittest
{
	alias NotifyFunction = void delegate(); // Must be a delegate if functions are inside the unittest block.
	Signals!NotifyFunction signals;

	size_t count;

	void firstFunc()
	{
		++count;
	}

	void secondFunc()
	{
		++count;
	}

	signals.connect(&firstFunc);
	signals.connect(&secondFunc);
	signals.emit();

	signals.disconnect(&firstFunc);
	signals.emit();

	signals.disconnectAll();
	signals.emit();

	count.should.equal(3);

	alias NotifyFuncWithArgs = void delegate(string value);
	Signals!NotifyFuncWithArgs argsSignals;
	string argsValue;

	void argsFunc(string value)
	{
		argsValue = "Hello " ~ value;
	}

	void argsFunc2(string value)
	{
		argsValue = "Goodbye " ~ value;
	}

	argsSignals.emit("World");
	argsValue.should.equal(string.init);

	argsSignals.connect(&argsFunc);
	argsSignals.connect(&argsFunc2);
	argsSignals.emit("World");

	argsValue.should.equal("Goodbye World");

	argsSignals.disconnect(&argsFunc2);
	argsSignals.emit("World");

	argsValue.should.equal("Hello World");

	alias NotifyDelegate = void delegate();

	class TestDelegates
	{
		this()
		{
			signals_.connect(&voidDel);
			signals_.connect(&voidDel2);
			signals_.emit();
			signals_.disconnect(&voidDel2);
			signals_.emit();
			signals_.disconnectAll();
			signals_.emit();
			signals_.connect(&voidDel3);
			signals_.emit();
		}

		void voidDel()
		{
			++count;
		}

		void voidDel2()
		{
			++count;
		}

		void voidDel3()
		{
			++count;
		}

		size_t getCount()
		{
			return count;
		}

	private:
		Signals!NotifyDelegate signals_;
		size_t count;
	}

	auto test = new TestDelegates;
	test.getCount.should.equal(4);
}
