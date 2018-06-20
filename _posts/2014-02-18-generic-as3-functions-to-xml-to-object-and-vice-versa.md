---
id: 156
title: Generic AS3-functions to convert XML to Object and vice versa
date: 2014-02-18T15:07:05+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=156
frutiful_posts_template:
  - "2"
categories:
  - Coding
tags:
  - as3
  - conversion
  - xml
---
Converting an Object in AS3 to XML and vice versa, can be really tricky. Basically you have these three options:

* Parse and deserialize yourself, mapping your XML to your own objects.
* Use a serializer / deserializer from a library.
* Cast as objects, use a HTTPService.

Since the first option is quite cumbersome ant the second and third option requires the use of external libraries or services, I wanted to write a simple function that can be used to convert ANY object to XML and ANY XML to a plain old object.

<!--more-->

## Converting XML to Object

The first function (`xmltobj`) the function to convert an XML String to an Object. It behaves as follows:

* Each node in the XML will be converted to an property on the object with the same name
* The value of the node will become the value of the property
* If a node contains multiple sub-nodes whereas each sub-node has a numeric name (<0/>, <1/>, etc.) the node will be automatically converted to an array on the object. The order of the sub-nodes wil be reflected in the order in the array, but the node name will not determine the index in the array.

```as3
package info.tiefenauer.util.global
{
	/**
	 * <p>Helper function to transform any XML to an Object</p>
	 * <p>Thisfunction recursively iterates through all child nodes of an XML and converts them to object attributes. The transformation is made as follows</p>
	 * <ul>
	 * 		<li>If the child node value is a <em>simple type</em> (not another XML), it is added to the object as a new attribute whereas the attribute name is equal
	 * 			to the child node name and the attribute value is equal to the child node value</li>
	 * 		<li>If the child node value is a <em>complex type</em>, the node value is converted into its object representation and then added to the object as an attribute,
	 *      whereas the attribute name is equal to the child node name. The attribute value is equal to the object representation of the child node value.</li>
	 * 		<li>If the child node name is a numeric value, the child node value is treated as an array element, and the array is added to the object as a new attribute. It is assumed
	 *      that all sibling nodes also numeric names. This way the arrays which were converted to XMLLists by <code>info.tiefenauer.util.global.obj2xml() can
	 * 			be transformed back into their array representation</li>
	 * </ul>
	 * <p>XMLs transformed with this function can afterwards be transformed back to their XML representation using <code>info.tiefenauer.util.global.obj2xml()</code>.</p>
	 * @param xml XML to be converted to an object
	 * @return Object representation of the XML
	 * @see info.tiefenauer.util.global#obj2xml()
	 */
	public function xml2obj(xml:XML):Object{
		var obj:Object = new Object();
		var arr:Array = new Array();

		var add:Function = function(key:String, item:*):void{
			if (!isNaN(Number(key))){
				arr.push(item);
			}
			else{
				if (item == 'true')
					obj[key] = true;
				else if (item == 'false')
					obj[key] = false;
				else
					obj[key] = item;
			}
		}

		// Es wird ein Array (bzw. XMLList)-Element geparst
		if (!isNaN(xml.localName())){
			var xmlContent:XML = xml.children()[0];
			return xml2obj(xmlContent);
		}
		else{
			for each(var node:XML in xml.children()){
				var key:String = node.localName();
				if(node.hasComplexContent()){
					var nestedObj:Object = xml2obj(node);
					add(key, nestedObj);
				}
				else{
					var value:String = String(node.text());
					if (isNaN(Number(value))){
						add(key, value);
					}
					else{
						add(key, parseInt(value));
					}
				}
			}
		}

		if (arr.length > 0)
			return arr;
		return obj;
	}
}
```

## Converting Object to XML

<span style="line-height: 1.5;">The counterpart (<code>obj2xml</code>) function to convert an Object to XML. It behaves as follows:</span>

* each property on the object will be converted to a corresponding node on the XML
* Simple types like String, int and Boolean will be directly taken over and no further-sub-nodes are created
* Complex types (other objects) will be recursively added as sub-nodes
* Arrays will be converted to XMLLists, where as the single node names will be the index in the array.

```as3
package info.tiefenauer.util.global
{
	/**
	 * <p>Helper function to transform any object to XML</p>
	 * <p>This function recursively iterates through all attributes of an object and transforms them to XML nodes. The transformations are made as follows</p>
	 * <ul>
	 *    <li>The name of the root node is taken from the <em>name</em> attribute</li>
	 * 		<li>If the attribute is of a <em>simple type</em> (i.e. String, int, Number or Boolean), it is appended as a simple child node to the XML.
	 * 			In this case, the name of the child node is equal to the name of the attribute. The value of the child node is equal to the value of
	 *      the attribute. Example: myObject.myAttribute becomes &lt;myObject&gt;&lt;myAttribute&gt;{value}&lt;/myAttribute&gt;&lt;/myObject&gt;</li>
	 * 		<li>If the attribute is of a <em>complex type</em> (i.e. another Object), a new XML is recursively generated and appended to the
	 *      XML as a complex child node. As with simple types, the node name is equal to the attribute name whereas the node value
	 *      is the XML representation of the attribute object. </li>
	 * 		<li>If the attribute is an Array, it is converted to a XMLList where the single child node names are the indexes and the child node
	 *      values are the corresponding values in the array. Example: ['value0', 'value1','value2'] becomes &lt;0&gt;value0&lt;/0&gt;&lt;1&gt;value1&lt;/1&gt;&lt;2&gt;value2&lt;/2&gt;</li>
	 * </ul>
	 * <p>Objects transformed with this function can afterwards be transformed back by using the xml2obj()-function.</p>
	 * @param name Name of the root node
	 * @return XML representation of the object
	 * @see info.tiefenauer.util.global#xml2obj()
	 */
	public function obj2xml(name:String, obj:Object):XML{
		var xml:XML = <{name}/>;
		var isSimpleType:Function = function(val:*):Boolean{
			return (val is String || val is int || val is Number || val is Boolean);
		};
		for (var key:String in obj){
			var value:* = obj[key];
			if (isSimpleType(value)){
				xml.appendChild(<{key}>{value}</{key}>);
			}
			else if (value is Array){
				var arr:Array = value as Array;
				var node:XML =<{key}/>;
				var list:XMLList = new XMLList();
				for (var i:int=0; i<arr.length;i++){
					if (isSimpleType(arr[i]))
						list[i] = <{i}>{arr[i]}</{i}>;
					else
						list[i] = obj2xml(key, arr[i]);
				}
				node.appendChild(list);
				xml.appendChild(node);
			}
			else{
				xml.appendChild(obj2xml(key, value));
			}
		}
		return xml;
	}
}
```

# Test Classes

Below are the sources including Unit Test classes used to test them:

```as3
package test.info.tiefenauer.util.global
{
	import info.tiefenauer.util.global.obj2xml;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	public class Obj2XMLTest
	{
		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/
		[Before]
		public function setUp():void
		{
		}

		[After]
		public function tearDown():void
		{
		}

		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}

		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/
		[Test(description="Simple, flat object with simple attributes")]
		public function shouldBeSimpleXML():void{
			var xml:XML = obj2xml('someObject', {
				attr1: 'someString',
				attr2: 42,
				attr3: true,
				attr4: new Number(42)
			});
			assertEquals('someObject', xml.localName());
			assertEquals('someString', String(xml.attr1));
			assertEquals('42', String(xml.attr2));
			assertEquals('true', String(xml.attr3));
			assertEquals('42', String(xml.attr4));
		}
		[Test(description="Object with a complex attribute of another object")]
		public function shouldBeComplexXML():void{
			var xml:XML = obj2xml('someObject', {
				attr1: 'someString',
				attr2: 42,
				attr3: true,
				attr4: new Number(42),
				nestedAttr: {
					nestedAttr1: 'someOtherString',
					nestedAttr2: 42,
					nestedAttr3: true,
					nestedAttr4: new Number(42)
				}
			});

			assertEquals('someString', String(xml.attr1));
			assertEquals('42', String(xml.attr2));
			assertEquals('true', String(xml.attr3));
			assertEquals('42', String(xml.attr4));

			assertTrue(xml.nestedAttr is XMLList);
			assertTrue(XMLList(xml.nestedAttr).hasComplexContent());
			var nestedXML:XMLList = xml.nestedAttr;
			assertEquals(nestedXML.nestedAttr1, 'someOtherString');
			assertEquals(nestedXML.nestedAttr2, '42');
			assertEquals(nestedXML.nestedAttr3, 'true');
			assertEquals(nestedXML.nestedAttr4, '42');
		}
		[Test(description="An array of simple types should be converted to an XMLList with the array indexes as child node names")]
		public function shouldBeSimpleXMLList():void{
			var xml:XML = obj2xml('someObject', {
				someArray: ['someString', 'someOtherString']
			});
			assertTrue(xml.someArray is XMLList);
			assertTrue(XMLList(xml.someArray).hasComplexContent());
			var nestedXML:XMLList = xml.someArray;
			assertEquals(2, nestedXML.children().length());
			assertEquals('someString', String(nestedXML.children()[0]));
			assertEquals('0', XML(nestedXML.children()[0]).localName());
			assertEquals('someOtherString', String(nestedXML.children()[1]));
			assertEquals('1', XML(nestedXML.children()[1]).localName());
		}
		[Test(description="An array of objects should be converted to an XMLList with the indexes as child node names and the XML representation of the objects as child node values")]
		public function shouldBeComplexXMLList():void{
			var xml:XML = obj2xml('someObject', {
				someArray: [
					{attr1: 'someString', attr2: 'someOtherString' },
					{simpleAttr: 'simpleAttr', complexAttr: { subSubAttr1: 'subSubAttr', subSubAttr2: 42 }}
				]
			});
			assertTrue(xml.someArray is XMLList);
			assertTrue(XMLList(xml.someArray).hasComplexContent());
			var nestedXML:XMLList = xml.someArray;
			assertEquals(2, nestedXML.children().length());
			var arrayElem1:XML = nestedXML.children()[0];
			var arrayElem2:XML = nestedXML.children()[1];
			// Array Element 1
			assertTrue(arrayElem1.hasComplexContent());
			assertEquals('someString', arrayElem1.attr1);
			assertEquals('someOtherString', arrayElem1.attr2);
			//Array Element 2
			assertTrue(arrayElem2.hasComplexContent());
			var subElem1:XMLList = arrayElem2.simpleAttr;
			var subElem2:XMLList = arrayElem2.complexAttr;
			assertTrue(subElem1.hasSimpleContent());
			assertEquals('simpleAttr', subElem1.text());
			assertTrue(subElem2.hasComplexContent());
			var subSubElem1:XMLList = subElem2.subSubAttr1;
			var subSubElem2:XMLList = subElem2.subSubAttr2;
			assertTrue(subSubElem1.hasSimpleContent());
			assertEquals('subSubAttr', subSubElem1.text());
			assertEquals('42', subSubElem2.text());
		}
	}
}
```

```as3
package test.info.tiefenauer.util.global
{
	import info.tiefenauer.util.global.xml2obj;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;

	public class XML2ObjTest
	{
		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/
		[Before]
		public function setUp():void
		{
		}

		[After]
		public function tearDown():void
		{
		}

		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}

		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/
		[Test(description="Simple, flat XML with simple nodes")]
		public function shouldBeSimpleObject():void{
			var obj:Object = xml2obj(
				<someObject>
					<stringAttr>someString</stringAttr>
					<booleanAttr>true</booleanAttr>
					<intAttr>42</intAttr>
				</someObject>
			);
			assertNotNull(obj);
			assertNotNull(obj['stringAttr']);
			assertNotNull(obj['booleanAttr']);
			assertNotNull(obj['intAttr']);
			assertTrue(obj['stringAttr'] is String);
			assertTrue(obj['booleanAttr'] is Boolean);
			assertTrue(obj['intAttr'] is int);
			assertEquals('someString', obj['stringAttr']);
			assertEquals(true, obj['booleanAttr']);
			assertEquals(42, obj['intAttr']);
		}
		[Test(description="Flat XML with a complex child node")]
		public function shouldBeComplexObject():void{
			var obj:Object = xml2obj(
				<someObject>
					<simpleAttr>someString</simpleAttr>
					<complexAttr>
						<nestedAttr1>someOtherString</nestedAttr1>
						<nestedAttr2>42</nestedAttr2>
					</complexAttr>
				</someObject>
			);
			assertNotNull(obj);
			assertNotNull(obj['simpleAttr']);
			assertNotNull(obj['complexAttr']);
			assertTrue(obj['simpleAttr'] is String);
			assertTrue(obj['complexAttr'] is Object);
			var nestedObj:Object = obj['complexAttr'];
			// nested Attribut 1
			assertNotNull(nestedObj['nestedAttr1']);
			assertTrue(nestedObj['nestedAttr1'] is String);
			assertEquals('someOtherString', nestedObj['nestedAttr1']);
			// nested Attribut 2
			assertNotNull(nestedObj['nestedAttr2']);
			assertTrue(nestedObj['nestedAttr2'] is int);
			assertEquals(42, nestedObj['nestedAttr2']);
		}
		[Test(description="XMLLists with numeric child nodes names should be transformed to arrays")]
		public function shouldBeNestedArray():void{
			var xml:XML = XML("<someObject>" +
								"<xmlArray>" +
									"<0>someString</0>" +
									"<1>someOtherString</1>" +
									"<2>42</2>" +
								"</xmlArray>" +
							"</someObject>");
			var obj:Object = xml2obj(xml);
			assertNotNull(obj);
			assertNotNull(obj['xmlArray']);
			assertTrue(obj['xmlArray'] is Array);
			var arr:Array = obj['xmlArray'];
			assertEquals(3, arr.length);
			assertEquals('someString', arr[0]);
			assertEquals('someOtherString', arr[1]);
			assertEquals(42, arr[2]);
		}
		[Test(description="An XMLList with numeric child node names and complex node values should be converted to an array of objects")]
		public function shouldBeNestedObjectArray():void{
			var xml:XML = XML("<someObject>" +
								"<xmlArray>" +
									"<0>simpleAttribute</0>" +
									"<1>" +
										"<complexAttribute>" +
											"<stringAttr>someString</stringAttr>" +
											"<intAttr>42</intAttr>" +
											"<booleanAttr>true</booleanAttr>" +
										"</complexAttribute>" +
									"</1>" +
								"</xmlArray>" +
							"</someObject>");
			var obj:Object = xml2obj(xml);
			assertNotNull(obj);
			assertNotNull(obj['xmlArray']);
			assertTrue(obj['xmlArray'] is Array);
			var arr:Array = obj['xmlArray'];
			assertEquals(2, arr.length);
			assertEquals('simpleAttribute', arr[0]);
			assertTrue(arr[1] is Object);
			var nestedObject:Object = arr[1];
			assertNotNull(nestedObject['stringAttr']);
			assertNotNull(nestedObject['intAttr']);
			assertNotNull(nestedObject['booleanAttr']);
			assertEquals('someString', nestedObject['stringAttr']);
			assertEquals(42, nestedObject['intAttr']);
			assertEquals(true, nestedObject['booleanAttr']);
		}
	}
}
```