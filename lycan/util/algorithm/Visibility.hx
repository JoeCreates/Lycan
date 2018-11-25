// Calculate visible area from a position
// Copyright 2012 Red Blob Games
// License: Apache v2

/*
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

/*
   This code uses the Haxe compiler, including some of the basic Haxe
   libraries, which are under the two-clause BSD license: http://haxe.org/doc/license

   Copyright (c) 2005, the haXe Project Contributors
   All rights reserved.
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

   * Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND
   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
   This code also uses a linked list datastructure class from
   Polygonal, which is Copyright (c) 2009-2010 Michael Baczynski,
   http://www.polygonal.de. It is available under the new BSD license,
   except for two algorithms, which I do not use. See
   https://github.com/polygonal/polygonal/blob/master/LICENSE
*/

package lycan.util.algorithm;

import de.polygonal.ds.DLL;

@:expose @:struct @:keep class Block {
    public var x:Float;
    public var y:Float;
    public var r:Float;
}
@:expose @:struct @:keep class Point {
    public var x:Float = 0.0;
    public var y:Float = 0.0;
    public function new(x_:Float, y_:Float) {
        this.x = x_;
        this.y = y_;
    }
}
@:expose @:struct @:keep class EndPoint extends Point {
    public var begin:Bool = false;
    public var segment:Segment = null;
    public var angle:Float = 0.0;
    public var visualize:Bool = false;
}
@:expose @:struct @:keep class Segment {
    public var p1:EndPoint;
    public var p2:EndPoint;
    public var d:Float;
    public function new() {}
}

/* 2d visibility algorithm, for demo
   Usage:
      new Visibility()
   Whenever map data changes:
      loadMap
   Whenever light source changes:
      setLightLocation
   To calculate the area:
      sweep
*/

@:expose @:keep class Visibility {
    // Note: DLL is a doubly linked list but an array would be ok too

    // These represent the map and the light location:
    public var segments:DLL<Segment>;
    public var endpoints:DLL<EndPoint>;
    public var center:Point;

    // These are currently 'open' line segments, sorted so that the nearest
    // segment is first. It's used only during the sweep algorithm, and exposed
    // as a public field here so that the demo can display it.
    public var open:DLL<Segment>;

    // The output is a series of points that forms a visible area polygon
    public var output:Array<Point>;

    // For the demo, keep track of wall intersections
    public var demo_intersectionsDetected:Array<Array<Point>>;


    // Construct an empty visibility set
    public function new() {
        segments = new DLL<Segment>();
        endpoints = new DLL<EndPoint>();
        open = new DLL<Segment>();
        center = new Point(0.0, 0.0);
        output = new Array();
        demo_intersectionsDetected = [];

        // Dummy call to make Haxe keep this function in the output
        segments.toArray();
    }


    // Helper function to construct segments along the outside perimeter
    private function loadEdgeOfMap(size:Int, margin:Int) {
        addSegment(margin, margin, margin, size-margin);
        addSegment(margin, size-margin, size-margin, size-margin);
        addSegment(size-margin, size-margin, size-margin, margin);
        addSegment(size-margin, margin, margin, margin);
        // NOTE: if using the simpler distance function (a.d < b.d)
        // then we need segments to be similarly sized, so the edge of
        // the map needs to be broken up into smaller segments.
    }


    // Load a set of square blocks, plus any other line segments
    public function loadMap(size, margin, blocks:Array<Block>, walls:Array<Segment>) {
        segments.clear();
        endpoints.clear();
        loadEdgeOfMap(size, margin);

        for (block in blocks) {
            var x = block.x;
            var y = block.y;
            var r = block.r;
            addSegment(x-r, y-r, x-r, y+r);
            addSegment(x-r, y+r, x+r, y+r);
            addSegment(x+r, y+r, x+r, y-r);
            addSegment(x+r, y-r, x-r, y-r);
        }
        for (wall in walls) {
            addSegment(wall.p1.x, wall.p1.y, wall.p2.x, wall.p2.y);
        }
    }


    // Add a segment, where the first point shows up in the
    // visualization but the second one does not. (Every endpoint is
    // part of two segments, but we want to only show them once.)
	public function addSegment(x1:Float, y1:Float, x2:Float, y2:Float) {
        var segment:Segment = null;
        var p1:EndPoint = new EndPoint(0.0, 0.0);
        p1.segment = segment;
        p1.visualize = true;
        var p2:EndPoint = new EndPoint(0.0, 0.0);
        p2.segment = segment;
        p2.visualize = false;
        segment = new Segment();
        p1.x = x1; p1.y = y1;
        p2.x = x2; p2.y = y2;
        p1.segment = segment;
        p2.segment = segment;
        segment.p1 = p1;
        segment.p2 = p2;
        segment.d = 0.0;

        segments.append(segment);
        endpoints.append(p1);
        endpoints.append(p2);
    }


    // Set the light location. Segment and EndPoint data can't be
    // processed until the light location is known.
    public function setLightLocation(x:Float, y:Float) {
        center.x = x;
        center.y = y;

        for (segment in segments) {
            var dx = 0.5 * (segment.p1.x + segment.p2.x) - x;
            var dy = 0.5 * (segment.p1.y + segment.p2.y) - y;
            // NOTE: we only use this for comparison so we can use
            // distance squared instead of distance. However in
            // practice the sqrt is plenty fast and this doesn't
            // really help in this situation.
            segment.d = dx*dx + dy*dy;

            // NOTE: future optimization: we could record the quadrant
            // and the y/x or x/y ratio, and sort by (quadrant,
            // ratio), instead of calling atan2. See
            // <https://github.com/mikolalysenko/compare-slope> for a
            // library that does this. Alternatively, calculate the
            // angles and use bucket sort to get an O(N) sort.
            segment.p1.angle = Math.atan2(segment.p1.y - y, segment.p1.x - x);
            segment.p2.angle = Math.atan2(segment.p2.y - y, segment.p2.x - x);

            var dAngle = segment.p2.angle - segment.p1.angle;
            if (dAngle <= -Math.PI) { dAngle += 2*Math.PI; }
            if (dAngle > Math.PI) { dAngle -= 2*Math.PI; }
            segment.p1.begin = (dAngle > 0.0);
            segment.p2.begin = !segment.p1.begin;
        }
    }


    // Helper: comparison function for sorting points by angle
    static private function _endpoint_compare(a:EndPoint, b:EndPoint):Int {
        // Traverse in angle order
        if (a.angle > b.angle) return 1;
        if (a.angle < b.angle) return -1;
        // But for ties (common), we want Begin nodes before End nodes
        if (!a.begin && b.begin) return 1;
        if (a.begin && !b.begin) return -1;
        return 0;
    }

    // Helper: leftOf(segment, point) returns true if point is "left"
    // of segment treated as a vector. Note that this assumes a 2D
    // coordinate system in which the Y axis grows downwards, which
    // matches common 2D graphics libraries, but is the opposite of
    // the usual convention from mathematics and in 3D graphics
    // libraries.
    static inline private function leftOf(s:Segment, p:Point):Bool {
        // This is based on a 3d cross product, but we don't need to
        // use z coordinate inputs (they're 0), and we only need the
        // sign. If you're annoyed that cross product is only defined
        // in 3d, see "outer product" in Geometric Algebra.
        // <http://en.wikipedia.org/wiki/Geometric_algebra>
        var cross = (s.p2.x - s.p1.x) * (p.y - s.p1.y)
                  - (s.p2.y - s.p1.y) * (p.x - s.p1.x);
        return cross < 0;
        // Also note that this is the naive version of the test and
        // isn't numerically robust. See
        // <https://github.com/mikolalysenko/robust-arithmetic> for a
        // demo of how this fails when a point is very close to the
        // line.
    }

    // Return p*(1-f) + q*f
    static private function interpolate(p:Point, q:Point, f:Float):Point {
        return new Point(p.x*(1-f) + q.x*f, p.y*(1-f) + q.y*f);
    }

    // Helper: do we know that segment a is in front of b?
    // Implementation not anti-symmetric (that is to say,
    // _segment_in_front_of(a, b) != (!_segment_in_front_of(b, a)).
    // Also note that it only has to work in a restricted set of cases
    // in the visibility algorithm; I don't think it handles all
    // cases. See http://www.redblobgames.com/articles/visibility/segment-sorting.html
    private function _segment_in_front_of(a:Segment, b:Segment, relativeTo:Point):Bool {
        // NOTE: we slightly shorten the segments so that
        // intersections of the endpoints (common) don't count as
        // intersections in this algorithm
        var A1 = leftOf(a, interpolate(b.p1, b.p2, 0.01));
        var A2 = leftOf(a, interpolate(b.p2, b.p1, 0.01));
        var A3 = leftOf(a, relativeTo);
        var B1 = leftOf(b, interpolate(a.p1, a.p2, 0.01));
        var B2 = leftOf(b, interpolate(a.p2, a.p1, 0.01));
        var B3 = leftOf(b, relativeTo);

        // NOTE: this algorithm is probably worthy of a short article
        // but for now, draw it on paper to see how it works. Consider
        // the line A1-A2. If both B1 and B2 are on one side and
        // relativeTo is on the other side, then A is in between the
        // viewer and B. We can do the same with B1-B2: if A1 and A2
        // are on one side, and relativeTo is on the other side, then
        // B is in between the viewer and A.
        if (B1 == B2 && B2 != B3) return true;
        if (A1 == A2 && A2 == A3) return true;
        if (A1 == A2 && A2 != A3) return false;
        if (B1 == B2 && B2 == B3) return false;

        // If A1 != A2 and B1 != B2 then we have an intersection.
        // Expose it for the GUI to show a message. A more robust
        // implementation would split segments at intersections so
        // that part of the segment is in front and part is behind.
        demo_intersectionsDetected.push([a.p1, a.p2, b.p1, b.p2]);
        return false;

        // NOTE: previous implementation was a.d < b.d. That's simpler
        // but trouble when the segments are of dissimilar sizes. If
        // you're on a grid and the segments are similarly sized, then
        // using distance will be a simpler and faster implementation.
    }


    // Run the algorithm, sweeping over all or part of the circle to find
    // the visible area, represented as a set of triangles
    public function sweep(maxAngle:Float=999.0) {
        output = [];  // output set of triangles
        demo_intersectionsDetected = [];
        endpoints.sort(_endpoint_compare, true);

        open.clear();
        var beginAngle = 0.0;

        // At the beginning of the sweep we want to know which
        // segments are active. The simplest way to do this is to make
        // a pass collecting the segments, and make another pass to
        // both collect and process them. However it would be more
        // efficient to go through all the segments, figure out which
        // ones intersect the initial sweep line, and then sort them.
        for (pass in 0...2) {
            for (p in endpoints) {
                if (pass == 1 && p.angle > maxAngle) {
                    // Early exit for the visualization to show the sweep process
                    break;
                }

                var current_old = open.isEmpty()? null : open.head.val;

                if (p.begin) {
                    // Insert into the right place in the list
                    var node = open.head;
                    while (node != null && _segment_in_front_of(p.segment, node.val, center)) {
                        node = node.next;
                    }
                    if (node == null) {
                        open.append(p.segment);
                    } else {
                        open.insertBefore(node, p.segment);
                    }
                }
                else {
                    open.remove(p.segment);
                }

                var current_new = open.isEmpty()? null : open.head.val;
                if (current_old != current_new) {
                    if (pass == 1) {
                        addTriangle(beginAngle, p.angle, current_old);
                    }
                    beginAngle = p.angle;
                }
            }
        }
    }


    public function lineIntersection(p1:Point, p2:Point, p3:Point, p4:Point):Point {
        // From http://paulbourke.net/geometry/lineline2d/
        var s = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x))
            / ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y));
        return new Point(p1.x + s * (p2.x - p1.x), p1.y + s * (p2.y - p1.y));
    }


    private function addTriangle(angle1:Float, angle2:Float, segment:Segment) {
        var p1:Point = center;
        var p2:Point = new Point(center.x + Math.cos(angle1), center.y + Math.sin(angle1));
        var p3:Point = new Point(0.0, 0.0);
        var p4:Point = new Point(0.0, 0.0);

        if (segment != null) {
            // Stop the triangle at the intersecting segment
            p3.x = segment.p1.x;
            p3.y = segment.p1.y;
            p4.x = segment.p2.x;
            p4.y = segment.p2.y;
        } else {
            // Stop the triangle at a fixed distance; this probably is
            // not what we want, but it never gets used in the demo
            p3.x = center.x + Math.cos(angle1) * 500;
            p3.y = center.y + Math.sin(angle1) * 500;
            p4.x = center.x + Math.cos(angle2) * 500;
            p4.y = center.y + Math.sin(angle2) * 500;
        }

        var pBegin = lineIntersection(p3, p4, p1, p2);

        p2.x = center.x + Math.cos(angle2);
        p2.y = center.y + Math.sin(angle2);
        var pEnd = lineIntersection(p3, p4, p1, p2);

        output.push(pBegin);
        output.push(pEnd);
    }
}