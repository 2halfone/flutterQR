import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_code_customizer/widgets/custom_dropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class PreviewScreen extends StatefulWidget {
  final bool isStatic;
  final bool useTemplate;

  const PreviewScreen({
    Key? key, 
    required this.isStatic, 
    this.useTemplate = false
  }) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> with SingleTickerProviderStateMixin {
  String qrData = 'https://example.com';
  Color qrColor = Colors.black;
  Color backgroundColor = Colors.white;
  String? selectedTemplate;
  String? selectedFrame;
  String dotStyle = 'square';
  String cornerStyle = 'square';
  String fontSize = '18';
  String fontStyle = 'normal';
  String textTransform = 'none';
  String fontFamily = 'Poppins';
  Color textColor = Colors.black;
  String textUnderQr = '';
  String honorific = '';
  double qrSize = 200;
  // Variabili per il logo
  File? logoImage;
  double logoSize = 40;
  final picker = ImagePicker();
  // Allineamento del testo
  TextAlign textAlignment = TextAlign.center;
  
  final TextEditingController _textController = TextEditingController(text: 'https://example.com');
  final TextEditingController _textUnderQrController = TextEditingController();
  
  // Controller e indici per i tab
  late TabController _tabController;
  int _selectedTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textUnderQrController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Opzioni per i menu dropdown
  final List<MenuItem> dotStyleOptions = [
    MenuItem(id: 'dot1', label: 'Square', value: 'square'),
    MenuItem(id: 'dot2', label: 'Rounded', value: 'rounded'),
    MenuItem(id: 'dot3', label: 'Extra Rounded', value: 'extra-rounded'),
    MenuItem(id: 'dot4', label: 'Dots', value: 'dots'),
    MenuItem(id: 'dot5', label: 'Classy', value: 'classy'),
  ];

  final List<MenuItem> cornerStyleOptions = [
    MenuItem(id: 'corner1', label: 'Square', value: 'square'),
    MenuItem(id: 'corner2', label: 'Extra Rounded', value: 'extra-rounded'),
  ];

  final List<MenuItem> frameStyleOptions = [
    MenuItem(id: 'frame0', label: 'None', value: 'none'),
    MenuItem(id: 'frame1', label: 'Flower Frame', value: 'flower-frame.png'),
    MenuItem(id: 'frame2', label: 'Hand Frame', value: 'hand-frame.png'),
    MenuItem(id: 'frame3', label: 'Heart Frame', value: 'heart-frame.png'),
    MenuItem(id: 'frame4', label: 'Star Frame', value: 'star-frame.png'),
    MenuItem(id: 'frame5', label: 'Sun Frame', value: 'sun-frame.png'),
  ];

  final List<MenuItem> backgroundOptions = [
    MenuItem(id: 'bg0', label: 'None', value: 'none'),
    MenuItem(id: 'bg1', label: 'Abstract', value: 'abstract-pattern.png'),
    MenuItem(id: 'bg2', label: 'Art Deco', value: 'art-deco-pattern.png'),
    MenuItem(id: 'bg3', label: 'Bird', value: 'bird-pattern.png'),
    MenuItem(id: 'bg4', label: 'Classic', value: 'classic-pattern.png'),
    MenuItem(id: 'bg5', label: 'Geometric', value: 'geometric-pattern.png'),
    MenuItem(id: 'bg6', label: 'Modern', value: 'modern-pattern.png'),
    MenuItem(id: 'bg7', label: 'Vintage', value: 'vintage-pattern.png'),
  ];

  final List<MenuItem> fontFamilyOptions = [
    MenuItem(id: 'font1', label: 'Poppins', value: 'Poppins'),
    MenuItem(id: 'font2', label: 'Roboto', value: 'Roboto'),
    MenuItem(id: 'font3', label: 'Montserrat', value: 'Montserrat'),
    MenuItem(id: 'font4', label: 'Open Sans', value: 'Open Sans'),
    MenuItem(id: 'font5', label: 'Lato', value: 'Lato'),
  ];

  final List<MenuItem> fontStyleOptions = [
    MenuItem(id: 'style1', label: 'Normal', value: 'normal'),
    MenuItem(id: 'style2', label: 'Bold', value: 'bold'),
    MenuItem(id: 'style3', label: 'Italic', value: 'italic'),
    MenuItem(id: 'style4', label: 'Bold Italic', value: 'bold-italic'),
    MenuItem(id: 'style5', label: 'Thin (100)', value: '100'),
    MenuItem(id: 'style6', label: 'Light (300)', value: '300'),
    MenuItem(id: 'style7', label: 'Medium (500)', value: '500'),
    MenuItem(id: 'style8', label: 'Extra Bold (800)', value: '800'),
    MenuItem(id: 'style9', label: 'Black (900)', value: '900'),
  ];

  final List<MenuItem> textTransformOptions = [
    MenuItem(id: 'case1', label: 'Normal', value: 'none'),
    MenuItem(id: 'case2', label: 'Uppercase', value: 'uppercase'),
    MenuItem(id: 'case3', label: 'Lowercase', value: 'lowercase'),
    MenuItem(id: 'case4', label: 'Capitalize', value: 'capitalize'),
  ];

  final List<MenuItem> honorificOptions = [
    MenuItem(id: 'hon0', label: 'None', value: ''),
    MenuItem(id: 'hon1', label: 'Mr.', value: 'Mr.'),
    MenuItem(id: 'hon2', label: 'Ms.', value: 'Ms.'),
    MenuItem(id: 'hon3', label: 'Mrs.', value: 'Mrs.'),
    MenuItem(id: 'hon4', label: 'Dr.', value: 'Dr.'),
    MenuItem(id: 'hon5', label: 'Prof.', value: 'Prof.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.useTemplate ? 'Custom Template QR' : (widget.isStatic ? 'Static QR Code' : 'Dynamic QR Code')),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR Code saved!')),
              );
              // TODO: Implement actual save functionality
            },
          ),
        ],
        bottom: !widget.useTemplate ? TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'Contenuto'),
            Tab(icon: Icon(Icons.palette), text: 'Stile'),
            Tab(icon: Icon(Icons.image), text: 'Decorazioni'),
            Tab(icon: Icon(Icons.text_fields), text: 'Testo'),
          ],
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
        ) : null,
      ),
      body: widget.useTemplate ? _buildTemplateContent() : TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildContentTab(),
          _buildStyleTab(),
          _buildDecorationsTab(),
          _buildTextTab(),
        ],
      ),
    );
  }

  // Tab per il contenuto QR
  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR Code Preview
          _buildQrPreview(),
          const SizedBox(height: 20),
          
          // QR Content Input
          const Text(
            'Contenuto QR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              hintText: 'Inserisci URL o testo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.link),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _textController.clear();
                  setState(() => qrData = '');
                },
              ),
            ),
            onChanged: (value) {
              setState(() {
                qrData = value;
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Dimensione QR
          _buildQrSizeControl(),
        ],
      ),
    );
  }
  
  // Tab per lo stile del QR
  Widget _buildStyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR Code Preview
          _buildQrPreview(),
          const SizedBox(height: 20),
          
          // QR Dot Style
          Row(
            children: [
              Expanded(
                child: MenuAnimation(
                  items: dotStyleOptions,
                  label: 'Stile Punti',
                  value: dotStyle,
                  onChange: (value) {
                    setState(() {
                      dotStyle = value;
                    });
                  },
                  padding: const EdgeInsets.only(right: 8),
                ),
              ),
              Expanded(
                child: MenuAnimation(
                  items: cornerStyleOptions,
                  label: 'Stile Angoli',
                  value: cornerStyle,
                  onChange: (value) {
                    setState(() {
                      cornerStyle = value;
                    });
                  },
                  padding: const EdgeInsets.only(left: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // QR Color
          _buildColorControls(),
        ],
      ),
    );
  }
  
  // Tab per le decorazioni
  Widget _buildDecorationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR Code Preview
          _buildQrPreview(),
          const SizedBox(height: 20),
          
          // Upload Logo
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Logo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      // Logo preview
                      GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: logoImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.file(
                                    logoImage!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tocca per\naggiungere',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Logo size controls
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dimensione Logo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: logoSize,
                              min: 20,
                              max: 100,
                              divisions: 16,
                              label: '${logoSize.round()}px',
                              onChanged: logoImage != null
                                  ? (value) {
                                      setState(() {
                                        logoSize = value;
                                      });
                                    }
                                  : null,
                            ),
                            
                            // Remove logo button
                            if (logoImage != null)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    logoImage = null;
                                  });
                                },
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Rimuovi logo'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Background Template
          const Text(
            'Sfondo QR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTemplateOption(null, 'Nessuno'),
                _buildTemplateOption('abstract-pattern.png', 'Astratto'),
                _buildTemplateOption('art-deco-pattern.png', 'Art Deco'),
                _buildTemplateOption('bird-pattern.png', 'Uccello'),
                _buildTemplateOption('classic-pattern.png', 'Classico'),
                _buildTemplateOption('geometric-pattern.png', 'Geometrico'),
                _buildTemplateOption('modern-pattern.png', 'Moderno'),
                _buildTemplateOption('vintage-pattern.png', 'Vintage'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Decorative Frame
          const Text(
            'Cornice Decorativa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFrameOption(null, 'Nessuna'),
                _buildFrameOption('flower-frame.png', 'Fiore'),
                _buildFrameOption('hand-frame.png', 'Mano'),
                _buildFrameOption('heart-frame.png', 'Cuore'),
                _buildFrameOption('star-frame.png', 'Stella'),
                _buildFrameOption('sun-frame.png', 'Sole'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Tab per il testo
  Widget _buildTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR Code Preview con testo
          _buildQrPreview(),
          const SizedBox(height: 20),
          
          // Text under QR Code
          const Text(
            'Testo sotto il QR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          
          // Honorific & Text input
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Honorific Menu (più compatto)
              Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                child: MenuAnimation(
                  items: honorificOptions,
                  label: 'Titolo',
                  value: honorific,
                  onChange: (value) {
                    setState(() {
                      honorific = value;
                    });
                  },
                ),
              ),
              // Text under QR input (resto dello spazio)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Testo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textUnderQrController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Testo da mostrare sotto il QR',
                      ),
                      onChanged: (value) {
                        setState(() {
                          textUnderQr = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Font settings in a card to group them
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stile font',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Font Family and Style
                  Row(
                    children: [
                      Expanded(
                        child: MenuAnimation(
                          items: fontFamilyOptions,
                          label: 'Famiglia',
                          value: fontFamily,
                          onChange: (value) {
                            setState(() {
                              fontFamily = value;
                            });
                          },
                          padding: const EdgeInsets.only(right: 8),
                        ),
                      ),
                      Expanded(
                        child: MenuAnimation(
                          items: fontStyleOptions,
                          label: 'Stile',
                          value: fontStyle,
                          onChange: (value) {
                            setState(() {
                              fontStyle = value;
                            });
                          },
                          padding: const EdgeInsets.only(left: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Font Size and Text Color in a more compact layout
                  Row(
                    children: [
                      // Font Size selector (slimmer)
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dimensione',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: double.parse(fontSize),
                                    min: 12,
                                    max: 36,
                                    divisions: 24,
                                    onChanged: (value) {
                                      setState(() {
                                        fontSize = value.toInt().toString();
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${fontSize}px',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Text Color picker (more compact)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Colore',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                _showColorPicker(
                                  context, 
                                  textColor, 
                                  (color) => setState(() => textColor = color)
                                );
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: textColor,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Scegli'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Text Case
                  MenuAnimation(
                    items: textTransformOptions,
                    label: 'Maiuscolo/Minuscolo',
                    value: textTransform,
                    onChange: (value) {
                      setState(() {
                        textTransform = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Allineamento testo (sinistra, centro, destra)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allineamento Testo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildAlignmentButton(TextAlign.left, Icons.format_align_left, 'Sinistra'),
                            _buildAlignmentButton(TextAlign.center, Icons.format_align_center, 'Centro'),
                            _buildAlignmentButton(TextAlign.right, Icons.format_align_right, 'Destra'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget per il contenuto del template
  Widget _buildTemplateContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // QR Code Preview
          _buildQrPreview(),
          const SizedBox(height: 20),
          
          // Content Input
          const Text(
            'Contenuto QR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Inserisci URL o testo',
              prefixIcon: const Icon(Icons.link),
            ),
            onChanged: (value) {
              setState(() {
                qrData = value;
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Template Options
          const Text(
            'Modello',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTemplateOption(null, 'Nessuno'),
                _buildTemplateOption('geometric-pattern.png', 'Geometrico'),
                _buildTemplateOption('abstract-pattern.png', 'Astratto'),
                _buildTemplateOption('modern-pattern.png', 'Moderno'),
                _buildTemplateOption('vintage-pattern.png', 'Vintage'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Frame Options
          const Text(
            'Cornice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFrameOption(null, 'Nessuna'),
                _buildFrameOption('flower-frame.png', 'Fiore'),
                _buildFrameOption('heart-frame.png', 'Cuore'),
                _buildFrameOption('star-frame.png', 'Stella'),
                _buildFrameOption('sun-frame.png', 'Sole'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Color Selection (più compatto)
          _buildColorControls(),
        ],
      ),
    );
  }
  
  // Widget centralizzato per il preview del QR
  Widget _buildQrPreview() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (selectedTemplate != null)
                    Image.asset(
                      'assets/backgrounds/$selectedTemplate',
                      width: 240,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                  QrImageView(
                    data: qrData.isEmpty ? 'https://example.com' : qrData,
                    version: QrVersions.auto,
                    size: qrSize,
                    backgroundColor: backgroundColor,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: qrColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: qrColor,
                    ),
                    // Aggiungiamo l'embedding del logo
                    embeddedImage: logoImage != null 
                        ? FileImage(logoImage!) as ImageProvider
                        : null,
                    embeddedImageStyle: logoImage != null
                        ? QrEmbeddedImageStyle(
                            size: Size(logoSize, logoSize),
                          )
                        : null,
                  ),
                  if (selectedFrame != null)
                    Image.asset(
                      'assets/frames/$selectedFrame',
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                    ),
                ],
              ),
              
              // Text under QR with all formatting
              if (textUnderQr.isNotEmpty || honorific.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Container(
                    width: double.infinity,
                    alignment: _getTextAlignment(),
                    child: RichText(
                      textAlign: textAlignment,
                      text: TextSpan(
                        children: [
                          if (honorific.isNotEmpty)
                            TextSpan(
                              text: '$honorific ',
                              style: _getTextStyle(
                                fontSize: double.parse(fontSize) * 0.8,
                                isBold: true,
                                color: Colors.black87,
                              ),
                            ),
                          TextSpan(
                            text: _getFormattedText(textUnderQr),
                            style: _getTextStyle(
                              fontSize: double.parse(fontSize),
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper per ottenere lo stile del testo con Google Fonts
  TextStyle _getTextStyle({
    required double fontSize,
    Color color = Colors.black,
    bool isBold = false,
  }) {
    // Ottiene lo stile base per il font selezionato
    TextStyle baseStyle;
    
    switch (fontFamily) {
      case 'Roboto':
        baseStyle = GoogleFonts.roboto(fontSize: fontSize, color: color);
        break;
      case 'Montserrat':
        baseStyle = GoogleFonts.montserrat(fontSize: fontSize, color: color);
        break;
      case 'Open Sans':
        baseStyle = GoogleFonts.openSans(fontSize: fontSize, color: color);
        break;
      case 'Lato':
        baseStyle = GoogleFonts.lato(fontSize: fontSize, color: color);
        break;
      case 'Poppins':
      default:
        baseStyle = GoogleFonts.poppins(fontSize: fontSize, color: color);
    }
    
    // Applica il peso (fontWeight) in base allo stile selezionato o al parametro isBold
    if (isBold) {
      baseStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    } else {
      baseStyle = baseStyle.copyWith(fontWeight: _getFontWeight());
    }
    
    // Applica lo stile corsivo se necessario
    if (fontStyle.contains('italic')) {
      baseStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);
    }
    
    return baseStyle;
  }
  
  // Widget per i controlli colore
  Widget _buildColorControls() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Colori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // QR Color and Background Color in a more compact format
            Row(
              children: [
                // QR Color
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Colore QR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          _showColorPicker(
                            context, 
                            qrColor, 
                            (color) => setState(() => qrColor = color)
                          );
                        },
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: qrColor,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Tocca per scegliere'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Background Color
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Colore Sfondo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          _showColorPicker(
                            context, 
                            backgroundColor, 
                            (color) => setState(() => backgroundColor = color)
                          );
                        },
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Tocca per scegliere'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget per il controllo della dimensione QR
  Widget _buildQrSizeControl() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dimensione QR',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: qrSize,
                    min: 100,
                    max: 350,
                    divisions: 25,
                    label: '${qrSize.round()}px',
                    onChanged: (value) {
                      setState(() {
                        qrSize = value;
                      });
                    },
                  ),
                ),
                Container(
                  width: 70,
                  alignment: Alignment.center,
                  child: Text(
                    '${qrSize.round()}px',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateOption(String? templateName, String label) {
    final bool isSelected = selectedTemplate == templateName;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTemplate = templateName;
          });
        },
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: templateName == null
                    ? const Center(child: Icon(Icons.block))
                    : Image.asset(
                        'assets/backgrounds/$templateName',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameOption(String? frameName, String label) {
    final bool isSelected = selectedFrame == frameName;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFrame = frameName;
          });
        },
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: frameName == null
                    ? const Center(child: Icon(Icons.block))
                    : Image.asset(
                        'assets/frames/$frameName',
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scegli un colore'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fatto'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  String _getFormattedText(String text) {
    switch (textTransform) {
      case 'uppercase':
        return text.toUpperCase();
      case 'lowercase':
        return text.toLowerCase();
      case 'capitalize':
        return text.split(' ').map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)).join(' ');
      default:
        return text;
    }
  }

  FontWeight _getFontWeight() {
    switch (fontStyle) {
      case 'bold':
        return FontWeight.bold;
      case '100':
        return FontWeight.w100;
      case '300':
        return FontWeight.w300;
      case '500':
        return FontWeight.w500;
      case '800':
        return FontWeight.w800;
      case '900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  Future<void> _pickLogo() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        logoImage = File(pickedFile.path);
      });
    }
  }
  
  Widget _buildAlignmentButton(TextAlign align, IconData icon, String tooltip) {
    return Expanded(
      child: IconButton(
        icon: Icon(icon),
        color: textAlignment == align ? Theme.of(context).primaryColor : Colors.grey,
        onPressed: () {
          setState(() {
            textAlignment = align;
          });
        },
        tooltip: tooltip,
      ),
    );
  }

  // Converte TextAlign in Alignment per il container
  Alignment _getTextAlignment() {
    switch (textAlignment) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.center:
      default:
        return Alignment.center;
    }
  }
}