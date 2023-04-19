(
w=Window.new;
v=UserView(w, w.view.bounds.insetBy(50,50));
v.resize = 5;
v.background_(Color.rand);
v.drawFunc={|uview|
        Pen.moveTo(0@uview.bounds.height.rand);
        Pen.lineTo(uview.bounds.width@uview.bounds.height.rand);
        Pen.stroke;
    };
v.mouseDownAction={v.refresh};
w.front;
)




(
var colors = [Color.blue, Color.red, Color.green];
a = Window.new;
q = 3;
​
b = Button(a, Rect(0, 0, 160, 20));
​
b.states = Array.fill(q, { arg i;
    [i.asString, Color.white, colors.wrapAt(i)]
});
​
b.action = { arg butt;
    p.visible = false;
    p = c.at(butt.value);
    p.visible = true;
};
​
c = Array.fill(q, { arg i;
    b = CompositeView(a, Rect(0, 25, 300, 300));
    b.background = colors[i].alpha_(0.2);
    b.visible = false;
    b;
});
​
5.do{ arg i; Slider(c[0], Rect(10, i * 30 + 10, 150, 25)).value_(1.0.rand) };
5.do{ arg i; Slider(c[1], Rect(i * 30 + 10, 10, 25, 150)).value_(1.0.rand) };
Slider2D(c[2], Rect(10, 10, 155, 150)).x_(1.0.rand).y_(1.0.rand);
​
p = c.at(0); // previous
p.visible = true; // show first one
​
a.front;
)