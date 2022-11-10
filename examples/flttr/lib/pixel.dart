import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker_web/image_picker_web.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class Pixel extends StatefulWidget {
  const Pixel({super.key});

  @override
  State<Pixel> createState() => _PixelState();
}

class _PixelState extends State<Pixel> {
  Image _image = Image.asset("assets/sample2.jpg");
  double _sliderBlockSize = 10;
  int _blockSize = 0;
  Uint8List? _imageBytes;

  int _imageWidth = 0;
  int _imageHeight = 0;

  ByteData? _imageBytes2;
  List<BlockOffset> _blocks = [];

  ByteData? imgBytes;

  img.Image? _image2;

  void _changeSlider(double e) => setState(() {
        _sliderBlockSize = e;
      });

  List<BlockOffset> getBlockList(double width, double height, int blockSize) {
    List<BlockOffset> blocks = [];
    for (double y = 1; y <= height; y += blockSize) {
      final double endY = y + blockSize > height ? height : y + blockSize;

      for (double x = 1; x <= width; x += blockSize) {
        final endX = x + blockSize > width ? width : x + blockSize;
        blocks.add(BlockOffset(Offset(x, y), Offset(endX, endY)));
      }
    }
    return blocks;
  }

  num _getColorDistance(Color color1, Color color2) {
    return pow(color2.red - color1.red, 2) +
        pow(color2.green - color1.green, 2) +
        pow(color2.blue - color1.blue, 2);
  }

  num _getColorDistanceAbs(Offset offset1, Offset offset2) {
    return _getColorDistance(
            _getColorAtOffset(offset1), _getColorAtOffset(offset2))
        .abs();
  }

  Color _getColorAtOffset(Offset offset) {
    return Color(_getHex(offset));
  }

  int _getHex(Offset offset) {
    return _abgrToArgb(
        _image2!.getPixelSafe(offset.dx.toInt(), offset.dy.toInt()));
  }

  int _abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

  Future<void> generateImage() async {
    _image2 = img.decodeImage(_imageBytes2!.buffer.asUint8List())!;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(Offset.zero,
            Offset(_imageWidth.toDouble(), _imageHeight.toDouble())));

    final paint = Paint();

    for (var b in _blocks) {
      List<Offset> uList = [];
      List<Offset> vList = [];
      Offset u = Offset.zero;
      Offset v = Offset.zero;

      if (_getColorDistanceAbs(b.leftTop, b.rightBottom) >
          _getColorDistanceAbs(b.rightTop, b.leftBottom)) {
        u = b.leftTop;
        v = b.rightBottom;
      } else {
        u = b.rightTop;
        v = b.leftBottom;
      }

      for (var y = b.start.dy; y <= b.end.dy; y++) {
        for (var x = b.start.dx; x <= b.end.dx; x++) {
          if (_getColorDistanceAbs(Offset(x, y), u) >
              _getColorDistanceAbs(Offset(x, y), v)) {
            vList.add(Offset(x, y));
          } else {
            uList.add(Offset(x, y));
          }
        }
      }

      final List<Offset> majoList = uList.length > vList.length ? uList : vList;

      final Map<String, int> sumColor =
          majoList.fold({"a": 0, "r": 0, "g": 0, "b": 0}, (p, e) {
        final color = _getColorAtOffset(e);
        return {
          "a": (p["a"] as int) + color.alpha,
          "r": (p["r"] as int) + color.red,
          "g": (p["g"] as int) + color.green,
          "b": (p["b"] as int) + color.blue
        };
      });

      paint.color = Color.fromARGB(
          (sumColor["a"] as int) ~/ majoList.length,
          (sumColor["r"] as int) ~/ majoList.length,
          (sumColor["g"] as int) ~/ majoList.length,
          (sumColor["b"] as int) ~/ majoList.length);

      canvas.drawRect(
          Rect.fromPoints(Offset(b.start.dx, b.start.dy),
              Offset(b.end.dx.toDouble(), b.end.dy)),
          paint);
    }
    final picture = recorder.endRecording();
    final iii = await picture.toImage(_imageWidth, _imageHeight);
    final pngBytes = await iii.toByteData(format: ui.ImageByteFormat.png);

    imgBytes = pngBytes;
  }

  @override
  void initState() {
    super.initState();
    _blockSize = _sliderBlockSize.toInt();
    _image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) async {
      final byteData =
          await info.image.toByteData(format: ui.ImageByteFormat.png);
      setState(() => _imageBytes = byteData!.buffer.asUint8List());

      Image.memory(_imageBytes!)
          .image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) async {
        final blockList = getBlockList(info.image.width.toDouble(),
            info.image.height.toDouble(), _blockSize);
        _blocks = blockList;
        _imageWidth = info.image.width;
        _imageHeight = info.image.height;
        _imageBytes2 =
            await info.image.toByteData(format: ui.ImageByteFormat.png);

        await generateImage();
        setState(() {});
      }));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: 'pixelize',
              style: const TextStyle(color: Colors.blue, fontSize: 30),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  await launchUrl(
                      Uri.parse("https://github.com/kyu-suke/f_pixelize"));
                }),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 500,
                child: _image,
              ),
              imgBytes != null
                  ? Image.memory(
                      Uint8List.view(imgBytes!.buffer),
                      width: _imageWidth.toDouble(),
                      height: _imageHeight.toDouble(),
                    )
                  : Container()
            ],
          ),
        ),
        Row(
          children: [
            Column(
              children: <Widget>[
                Text("block size: ${_sliderBlockSize.toInt()}"),
                SizedBox(
                  width: 500,
                  child: Slider(
                    label: '${_sliderBlockSize.toInt()}',
                    min: 1,
                    max: 100,
                    value: _sliderBlockSize,
                    divisions: 100,
                    onChanged: _changeSlider,
                  ),
                )
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final image = await ImagePickerWeb.getImageAsWidget();
                if (image == null) return;
                _image = image;
                _image.image.resolve(const ImageConfiguration()).addListener(
                    ImageStreamListener((ImageInfo info, bool _) async {
                  final byteData = await info.image
                      .toByteData(format: ui.ImageByteFormat.png);
                  setState(() => _imageBytes = byteData!.buffer.asUint8List());

                  final blockList = getBlockList(info.image.width.toDouble(),
                      info.image.height.toDouble(), _blockSize);
                  _blocks = blockList;
                  _imageWidth = info.image.width;
                  _imageHeight = info.image.height;
                  _imageBytes2 = await info.image
                      .toByteData(format: ui.ImageByteFormat.png);
                  setState(() {});
                }));
              },
              child: const Text('upload image'),
            ),
            ElevatedButton(
              onPressed: () async {
                _blockSize = _sliderBlockSize.toInt();
                final blockList = getBlockList(_imageWidth.toDouble(),
                    _imageHeight.toDouble(), _blockSize);
                _blocks = blockList;
                await generateImage();
                setState(() {});
              },
              child: const Text('convert'),
            ),
            ElevatedButton(
              onPressed: () async {
                final base64data = base64Encode(imgBytes!.buffer.asUint8List());
                final a = html.AnchorElement(
                    href: 'data:image/jpeg;base64,$base64data');
                a.download = 'download.jpg';
                a.click();
                a.remove();
              },
              child: const Text('save image'),
            ),
          ],
        ),
      ],
    );
  }
}

class BlockOffset {
  BlockOffset(this.start, this.end);

  Offset start;
  Offset end;

  Offset get leftTop => start;

  Offset get rightTop => Offset(end.dx, start.dy);

  Offset get leftBottom => Offset(start.dx, end.dy);

  Offset get rightBottom => end;
}
