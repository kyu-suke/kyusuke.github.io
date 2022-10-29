import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:f_glitch/f_glitch.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class Glitch extends StatefulWidget {
  const Glitch({Key? key}) : super(key: key);

  @override
  State<Glitch> createState() => _GlitchState();
}

class _GlitchState extends State<Glitch> {
  ImageProvider _imageProvider = const AssetImage('assets/sample.jpg');
  double _frequency = 1000;
  double _glitchRate = 50;
  Uint8List? _exportedImageByte;

  void _changeSlider(double e) => setState(() {
        _frequency = e;
        controller.setFrequency(_frequency.toInt());
      });

  void _changeGlitchSlider(double e) => setState(() {
        _glitchRate = e;
        controller.setGlitchRate(_glitchRate.toInt());
      });

  GlitchController controller = GlitchController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: 'f_glitch',
                style: const TextStyle(color: Colors.blue, fontSize: 30),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    await launchUrl(
                        Uri.parse("https://pub.dev/packages/f_glitch"));
                  }),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 260,
                height: 400,
                child: FGlitch(
                  imageProvider: _imageProvider,
                  controller: controller,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              if (_exportedImageByte != null)
                Image.memory(
                  Uint8List.view(_exportedImageByte!.buffer),
                ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(children: <Widget>[
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _imageProvider = const AssetImage('assets/sample.jpg');
                });
              },
              child: const Text('local image'),
            ),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _imageProvider = const NetworkImage(
                      "https://source.unsplash.com/M6ule9BFwYg");
                });
              },
              child: const Text('network image'),
            ),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                Image? image = await ImagePickerWeb.getImageAsWidget();
                if (image == null) return;
                setState(() {
                  _imageProvider = image.image;
                });
              },
              child: const Text('upload image'),
            ),
          ]),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  controller.play();
                },
                child: const Text('play'),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  controller.pause();
                },
                child: const Text('pause'),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  controller.glitch();
                },
                child: const Text('glitch'),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  controller.reset();
                },
                child: const Text('reset'),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  final image = await controller.asImage();
                  final imageByte =
                      await image.toByteData(format: ImageByteFormat.png);
                  setState(() {
                    _exportedImageByte = imageByte!.buffer.asUint8List();
                  });
                },
                child: const Text('export as image'),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  final base64data = base64Encode(_exportedImageByte!);
                  final a = html.AnchorElement(
                      href: 'data:image/jpeg;base64,$base64data');
                  a.download = 'download.jpg';
                  a.click();
                  a.remove();
                },
                child: const Text('save exported image'),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: <Widget>[
              Text("glitch interval: ${_frequency.toInt()}"),
              SizedBox(
                width: 500,
                child: Slider(
                  label: '${_frequency.toInt()}',
                  min: 100,
                  max: 5000,
                  value: _frequency,
                  divisions: 100,
                  onChanged: _changeSlider,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: <Widget>[
              Text("effect occurrence rate: ${_glitchRate.toInt()}"),
              SizedBox(
                width: 500,
                child: Slider(
                  label: '${_glitchRate.toInt()}',
                  min: 0,
                  max: 100,
                  value: _glitchRate,
                  divisions: 100,
                  onChanged: _changeGlitchSlider,
                ),
              ),
            ],
          ),
        ]);
  }
}
