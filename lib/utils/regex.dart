RegExp numberRegex = RegExp(r'(\d+)(?=_|\@|\.)'); // Check xxx_1. xxx_1_xxx.png
RegExp imageStringRegex = RegExp(r'''(?:'|").*\.(?:jpg|gif|png|webp)(?:'|")''');
RegExp quoteRegex = RegExp('''(?:'|")''');
String stringInterpolationPattern = r'\$(\w+|\{[^{}]+\})';
