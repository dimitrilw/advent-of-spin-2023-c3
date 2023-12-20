use spin_sdk::{
    http::{IntoResponse, Json /* , Request */},
    http_component, llm,
};
use serde::{Serialize, Deserialize};
use rand::seq::SliceRandom;

#[derive(Debug, Deserialize)]
struct Data {
    place: String,
    characters: Vec<String>,
    objects: Vec<String>,

    #[serde(default)]
    style: String,
}

impl Data {
    fn to_prompt(&self) -> String {
        format!(
            "please generate a winter holiday story that: \
            references the Rust programming language and/or crabs; \
            and takes place at {}; \
            and contains these characters: a bunny, {}; \
            and references these objects: {}; \
            and is written in the style of {}; \
            and is limited to 500 words.",
            self.place,
            self.characters.join(", "),
            self.objects.join(", "),
            self.style,
        )
    }
}

#[derive(Debug, Serialize)]
struct Payload {
    story: String,
    style: String,
    ns: i64,
}

const STYLES: &str = include_str!("../../assets/styles.json");

#[derive(Debug, Deserialize)]
struct Styles {
    styles: Vec<String>
}

#[http_component]
fn handle_rust_api(req: http::Request<Json<Data>>) -> anyhow::Result<impl IntoResponse> {
    let start = std::time::Instant::now();

    let mut d = Data {
        place: req.body().place.clone(),
        characters: req.body().characters.clone(),
        objects: req.body().objects.clone(),
        style: req.body().style.clone(),
    };
    println!("rust-api, data: {:?}", &d);

    if d.style.is_empty() {
        let s: Styles = serde_json::from_str(STYLES)?;
        d.style = s.styles.choose(&mut rand::thread_rng()).unwrap().clone();
    }

    let mut p = Payload {
        story: "ERROR: Inference failed.".to_string(),
        style: d.style.clone(),
        ns: -1,
    };

    let mut status_code = http::StatusCode::INTERNAL_SERVER_ERROR;

    let inference = llm::infer_with_options(
        llm::InferencingModel::Llama2Chat,
        &d.to_prompt(),
        llm::InferencingParams {
            max_tokens: 500,
            temperature: 0.9,
            top_p: 1.0,
            ..Default::default()
        },
    );

    if let Ok(result) = &inference {
        p.story = result.text.to_string();
        status_code = http::StatusCode::OK;
    }
    
    p.ns = start.elapsed().as_nanos() as i64;

    let body: String = serde_json::to_string(&p)?;

    println!("rust-api, payload: {:?}", &p);

    Ok(http::Response::builder()
        .status(status_code)
        .header("content-type", "application/json")
        .body(Some(body))?)
} // fn handle_rust_api