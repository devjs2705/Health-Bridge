import os
import gradio as gr
from deep_translator import GoogleTranslator
from brain_of_the_doctor import encode_image, analyze_image_with_query
from voice_of_the_patient import lanuage_detect, translate_transcribe_groq
from voice_of_the_doctor import text_to_speech_with_gtts

# Prompt to ask model to include specialist
system_prompt = """You have to act as a professional doctor, I know you are not but this is for learning purposes. 
What's in this image? Do you find anything wrong with it medically? 
If you make a differential, suggest some remedies for them. Do not add any numbers or special characters in 
your response. Your response should be in one long paragraph. Also, always answer as if you are answering to a real person.
Do not say 'In the image I see' but say 'With what I see, I think you have ....'
Don't respond as an AI model in markdown; your answer should mimic that of an actual doctor, not an AI bot. 
Keep your answer concise (max 2 sentences). No preamble, start your answer right away please. 
Mention which type of medical specialist the person should consult at the end of your response in a natural way."""

# Function to extract specialist from model output
def extract_specialist(text):
    specialties = [
        "dermatologist", "cardiologist", "neurologist", "orthopedist", "psychiatrist",
        "pediatrician", "gastroenterologist", "endocrinologist", "oncologist", "ophthalmologist",
        "dentist", "ENT", "gynecologist", "urologist", "pulmonologist", "nephrologist", "rheumatologist"
    ]
    text_lower = text.lower()
    for specialty in specialties:
        if specialty.lower() in text_lower:
            return specialty
    return "general physician"

# Main logic
def process_inputs(audio_filepath, image_filepath):
    speech_to_text_output = translate_transcribe_groq(
        GROQ_API_KEY=os.environ.get("GROQ_API_KEY"),
        audio_filepath=audio_filepath,
        stt_model="whisper-large-v3"
    )

    # Image analysis
    if image_filepath:
        doctor_response = analyze_image_with_query(
            query=system_prompt + speech_to_text_output,
            encoded_image=encode_image(image_filepath),
            model="meta-llama/llama-4-scout-17b-16e-instruct"
        )
    else:
        doctor_response = "No image provided for me to analyze"

    # Language detection
    lang = lanuage_detect(audio_filepath)

    # Text-to-speech
    voice_of_doctor = text_to_speech_with_gtts(
        input_text=doctor_response,
        output_filepath="final.mp3",
        language=lang
    )

    # Translation
    translated_text_patient = GoogleTranslator(source='auto', target=lang).translate(speech_to_text_output)
    doctor_response_translated = GoogleTranslator(source='auto', target=lang).translate(doctor_response)

    # Extract recommended specialist
    specialist = extract_specialist(doctor_response)

    return translated_text_patient, doctor_response_translated, voice_of_doctor, specialist

# Generate Google Search URL as clickable Markdown
def find_hospitals(specialist):
    if specialist:
        query = f"nearest {specialist} hospital near me"
    else:
        query = "nearest hospital near me"
    search_url = f"https://www.google.com/search?q={query.replace(' ', '+')}"
    return f"[🔗 Click here to view nearby {specialist.title()} hospitals]({search_url})"

# Build the Gradio UI
with gr.Blocks() as iface:
    gr.Markdown("## 🩺 AI Doctor with Vision, Voice & Nearby Hospital Finder")

    with gr.Row():
        audio_input = gr.Audio(sources=["microphone"], type="filepath", label="🎙️ Speak Your Symptoms")
        image_input = gr.Image(type="filepath", label="📷 Upload Image (Optional)")

    with gr.Row():
        submit_btn = gr.Button("🔍 Diagnose")

    with gr.Row():
        patient_text = gr.Textbox(label="🗣️ Translated Speech to Text")
        doctor_text = gr.Textbox(label="🧑‍⚕️ Doctor's Recommendation")

    voice_output = gr.Audio("final.mp3", label="🎧 Voice Response")
    specialist_box = gr.Textbox(label="🏥 Recommended Specialist")

    with gr.Row():
        find_button = gr.Button("📍 Find Nearest Hospital")
        map_output = gr.Markdown()

    # Function connections
    submit_btn.click(
        fn=process_inputs,
        inputs=[audio_input, image_input],
        outputs=[patient_text, doctor_text, voice_output, specialist_box]
    )

    find_button.click(
        fn=find_hospitals,
        inputs=[specialist_box],
        outputs=[map_output]
    )

iface.launch(debug=True)